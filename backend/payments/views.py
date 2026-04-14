import hashlib
import logging
import uuid

from django.conf import settings
from django.db import transaction as db_transaction
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from wallet.services import try_credit_wallet_topup

from .models import PaymentTransaction, SavedCard
from .serializers import (
    CardChargeSerializer,
    CreateSnapTransactionSerializer,
    PaymentTransactionSerializer,
    SavedCardSerializer,
)
from .services import MidtransAPIError, MidtransService
from .shop_order_settle import try_settle_shop_order_payment

logger = logging.getLogger("mixera.payments")


class CreateSnapTransactionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = CreateSnapTransactionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # Wallet top-up is card-only. Keep endpoint for backward compatibility
        # but reject wallet top-up Snap requests explicitly.
        if serializer.validated_data.get("purpose") == "wallet_topup":
            return Response(
                {"detail": "Wallet top-up via Snap is disabled. Please use card payment."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        amount = serializer.validated_data["amount"]
        purpose = serializer.validated_data["purpose"]

        order_id = f"MXR-{uuid.uuid4().hex[:16].upper()}"

        payload = {
            "transaction_details": {
                "order_id": order_id,
                "gross_amount": amount,
            },
            "customer_details": {
                "first_name": request.user.username,
                "email": request.user.email,
                "phone": request.user.phone_number or "",
            },
            "item_details": [
                {
                    "id": purpose,
                    "price": amount,
                    "quantity": 1,
                    "name": "Mixera Wallet Top Up",
                }
            ],
            "custom_field1": purpose,
            "custom_field2": str(request.user.id),
        }

        if settings.MIDTRANS_NOTIFICATION_URL:
            payload["notification_url"] = settings.MIDTRANS_NOTIFICATION_URL

        midtrans_response = MidtransService.create_snap_transaction(payload)

        tx = PaymentTransaction.objects.create(
            user=request.user,
            order_id=order_id,
            purpose=purpose,
            payment_method_type="snap",
            gross_amount=amount,
            transaction_status="pending",
            snap_token=midtrans_response.get("token"),
            redirect_url=midtrans_response.get("redirect_url"),
            raw_response=midtrans_response,
        )

        return Response(
            PaymentTransactionSerializer(tx).data,
            status=status.HTTP_201_CREATED,
        )


class CardChargeView(APIView):
    """
    Core API card charge for shop orders and wallet top-up.
    Frontend obtains a one-time card_token via Midtrans.js,
    or supplies a saved_token_id from a previously saved card.
    """
    permission_classes = [IsAuthenticated]

    @staticmethod
    def _build_new_card_payload(*, gross_amount, request, midtrans_order_id, card_token, save_card):
        # Midtrans Core API expects `save_token_id` on credit_card (not `save_card`).
        credit_card = {
            "token_id": card_token,
            "authentication": True,
        }
        if save_card:
            credit_card["save_token_id"] = True

        payload = {
            "payment_type": "credit_card",
            "transaction_details": {
                "order_id": midtrans_order_id,
                "gross_amount": gross_amount,
            },
            "credit_card": credit_card,
            "customer_details": {
                "first_name": request.user.username,
                "email": request.user.email,
                "phone": request.user.phone_number or "",
            },
            # After 3DS the browser redirects to this URL. The Flutter WebView
            # intercepts it (non-Midtrans domain) and starts polling for status.
            "callbacks": {"finish": "mixera://3ds/done"},
        }
        return payload

    @staticmethod
    def _build_saved_card_payload(*, gross_amount, request, midtrans_order_id, saved_token_id):
        """
        Recurring / one-click: Midtrans doc "Charge API Request for Recurring Transactions"
        only sends `credit_card.token_id` = saved_token_id — **not** `authentication`.
        Sending `authentication: true` makes Midtrans treat the token as a one-shot JS token
        and respond with e.g. validation_messages: ['unsupported token type'].
        See https://docs.midtrans.com/docs/coreapi-advanced-features
        """
        payload = {
            "payment_type": "credit_card",
            "transaction_details": {
                "order_id": midtrans_order_id,
                "gross_amount": gross_amount,
            },
            "credit_card": {
                "token_id": saved_token_id,
            },
            "customer_details": {
                "first_name": request.user.username,
                "email": request.user.email,
                "phone": request.user.phone_number or "",
            },
            # Finish URL if Midtrans still returns a 3DS redirect for this MID/card.
            "callbacks": {"finish": "mixera://3ds/done"},
        }
        return payload

    @staticmethod
    def _merge_midtrans_status_for_saved_card(payload: dict) -> dict:
        """
        Notifikasi HTTP sering tidak menyertakan saved_token_id (terutama setelah 3DS);
        Core API GET /v2/{order_id}/status biasanya melengkapi field tersebut.
        """
        merged = dict(payload)
        oid = merged.get("order_id")
        if merged.get("saved_token_id") or not oid:
            return merged
        try:
            st = MidtransService.get_transaction_status(str(oid))
            if isinstance(st, dict):
                for key in (
                    "saved_token_id",
                    "masked_card",
                    "bank",
                    "card_type",
                    "card_exp_month",
                    "card_exp_year",
                ):
                    if merged.get(key) in (None, "") and st.get(key) not in (None, ""):
                        merged[key] = st.get(key)
        except Exception as exc:
            logger.warning("Midtrans status lookup for saved_token order=%s: %s", oid, exc)
        return merged

    @staticmethod
    def _upsert_saved_card(*, user, response_payload):
        if not isinstance(response_payload, dict):
            return
        merged = CardChargeView._merge_midtrans_status_for_saved_card(response_payload)
        saved_token_id = merged.get("saved_token_id")
        if not saved_token_id or SavedCard.objects.filter(saved_token_id=saved_token_id).exists():
            if merged.get("order_id"):
                logger.info(
                    "saved card skip user=%s order=%s reason=%s",
                    user.pk,
                    merged.get("order_id"),
                    "no saved_token_id" if not saved_token_id else "duplicate token",
                )
            return
        is_first = not SavedCard.objects.filter(user=user).exists()
        SavedCard.objects.create(
            user=user,
            card_brand=str(merged.get("bank") or ""),
            masked_card=str(merged.get("masked_card") or ""),
            saved_token_id=saved_token_id,
            expiry_month=str(merged.get("card_exp_month") or "")[:2],
            expiry_year=str(merged.get("card_exp_year") or "")[:4],
            card_type=str(merged.get("card_type") or ""),
            is_default=is_first,
        )
        logger.info("saved card created user=%s masked=%s", user.pk, merged.get("masked_card"))

    @staticmethod
    def _is_saved_token_error(exc: MidtransAPIError) -> bool:
        """Midtrans rejects saved-token charge → ask user to pay with a fresh card token."""
        msgs = exc.response_json.get("validation_messages")
        if isinstance(msgs, list):
            vm = " ".join(str(m) for m in msgs).lower()
        else:
            vm = str(msgs or "").lower()
        raw = " ".join(
            [
                str(exc).lower(),
                str(exc.response_json.get("status_message", "")).lower(),
                vm,
            ]
        )
        tokenish = (
            "token",
            "saved_token",
            "saved token",
            "unsupported",
            "expired",
            "invalid",
            "revoke",
            "not found",
            "timed out",
            "timeout",
            "missing",
        )
        return any(t in raw for t in tokenish)

    def post(self, request):
        serializer = CardChargeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        charge_purpose = serializer.validated_data["charge_purpose"]
        card_token = (serializer.validated_data.get("card_token") or "").strip()
        saved_card_id = serializer.validated_data.get("saved_card_id")
        save_card = serializer.validated_data["save_card"]
        retry_three_ds = bool(serializer.validated_data.get("retry_three_ds"))

        charge_mode = "new_card"
        saved_card_obj = None

        # If the client sends both, a fresh Midtrans.js token must win — avoids
        # charging saved_token after the UI chose "new card" but still had an id.
        if saved_card_id and not card_token:
            try:
                saved_card_obj = SavedCard.objects.get(pk=saved_card_id, user=request.user)
                charge_mode = "saved_card"
            except SavedCard.DoesNotExist:
                return Response({"detail": "Saved card not found."}, status=status.HTTP_404_NOT_FOUND)

        from orders.models import Order

        linked_order_id = None
        gross_amount = 0
        midtrans_order_id = ""

        if charge_purpose == CardChargeSerializer.CHARGE_PURPOSE_SHOP:
            django_order_id = serializer.validated_data["django_order_id"]
            try:
                order = Order.objects.get(pk=django_order_id, user=request.user)
            except Order.DoesNotExist:
                return Response({"detail": "Order not found."}, status=status.HTTP_404_NOT_FOUND)

            if order.payment_status == "paid":
                return Response({"detail": "Order already paid."}, status=status.HTTP_400_BAD_REQUEST)

            gross_amount = int(order.total)
            linked_order_id = django_order_id
            midtrans_order_id = f"MXR-ORD-{django_order_id}-{uuid.uuid4().hex[:8].upper()}"

            existing_tx = PaymentTransaction.objects.filter(
                linked_order_id=django_order_id,
                user=request.user,
                purpose="shop_order",
                transaction_status="pending",
            ).first()
        else:
            gross_amount = int(serializer.validated_data["amount"])
            midtrans_order_id = f"MXR-WLT-{request.user.id}-{uuid.uuid4().hex[:12].upper()}"
            existing_tx = PaymentTransaction.objects.filter(
                user=request.user,
                purpose="wallet_topup",
                payment_method_type="card",
                transaction_status="pending",
                gross_amount=gross_amount,
            ).first()

        if charge_mode == "saved_card":
            payload = self._build_saved_card_payload(
                gross_amount=gross_amount,
                request=request,
                midtrans_order_id=midtrans_order_id,
                saved_token_id=saved_card_obj.saved_token_id,
            )
        else:
            payload = self._build_new_card_payload(
                gross_amount=gross_amount,
                request=request,
                midtrans_order_id=midtrans_order_id,
                card_token=card_token,
                save_card=save_card,
            )

        if settings.MIDTRANS_NOTIFICATION_URL:
            payload["notification_url"] = settings.MIDTRANS_NOTIFICATION_URL

        if existing_tx and not retry_three_ds:
            return Response(PaymentTransactionSerializer(existing_tx).data, status=status.HTTP_200_OK)
        if existing_tx and retry_three_ds:
            existing_tx.transaction_status = "cancel"
            existing_tx.save(update_fields=["transaction_status", "updated_at"])
            logger.info(
                "cancelled pending card tx for 3DS retry purpose=%s old_midtrans=%s",
                charge_purpose,
                existing_tx.order_id,
            )

        try:
            midtrans_response = MidtransService.charge_card(payload)
        except MidtransAPIError as exc:
            logger.warning(
                "Midtrans charge failed user=%s mode=%s http_status=%s response=%s",
                request.user.pk,
                charge_mode,
                exc.status_code,
                exc.response_json,
            )
            if charge_mode == "saved_card" and self._is_saved_token_error(exc):
                return Response(
                    {
                        "detail": "Saved card token is invalid or expired. Please use a new card.",
                        "code": "saved_card_token_invalid",
                        "action": "use_new_card",
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )
            return Response({"detail": str(exc)}, status=status.HTTP_502_BAD_GATEWAY)
        except Exception as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_502_BAD_GATEWAY)

        tx_status = midtrans_response.get("transaction_status", "pending")
        fraud = midtrans_response.get("fraud_status")

        tx = PaymentTransaction.objects.create(
            user=request.user,
            order_id=midtrans_order_id,
            purpose=charge_purpose,
            payment_method_type="card",
            gross_amount=gross_amount,
            transaction_status=tx_status,
            fraud_status=fraud,
            payment_type=midtrans_response.get("payment_type"),
            linked_order_id=linked_order_id,
            redirect_url=midtrans_response.get("redirect_url"),
            raw_response=midtrans_response,
        )

        if charge_purpose == CardChargeSerializer.CHARGE_PURPOSE_SHOP:
            if tx_status in ("capture", "settlement") and fraud in ("accept", None, ""):
                if try_settle_shop_order_payment(tx=tx):
                    logger.info(
                        "shop_order settled order_id=%s tx=%s",
                        linked_order_id,
                        midtrans_order_id,
                    )
        elif tx_status in ("capture", "settlement") and fraud in ("accept", None, ""):
            if try_credit_wallet_topup(
                user=request.user,
                gross_amount=gross_amount,
                payment_order_id=midtrans_order_id,
            ):
                logger.info("wallet_topup credited tx=%s", midtrans_order_id)

        if save_card and charge_mode == "new_card":
            self._upsert_saved_card(user=request.user, response_payload=midtrans_response)

        return Response(PaymentTransactionSerializer(tx).data, status=status.HTTP_201_CREATED)


class MidtransNotificationView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        payload = request.data

        order_id = payload.get("order_id")
        status_code = payload.get("status_code")
        gross_amount = payload.get("gross_amount")
        signature_key = payload.get("signature_key")

        expected_signature = hashlib.sha512(
            f"{order_id}{status_code}{gross_amount}{settings.MIDTRANS_SERVER_KEY}".encode()
        ).hexdigest()

        if signature_key != expected_signature:
            return Response(
                {"detail": "Invalid signature."},
                status=status.HTTP_403_FORBIDDEN,
            )

        tx = PaymentTransaction.objects.filter(order_id=order_id).first()
        if not tx:
            return Response({"detail": "Transaction not found."}, status=status.HTTP_404_NOT_FOUND)

        prev_status = tx.transaction_status
        tx.transaction_status = payload.get("transaction_status", tx.transaction_status)
        tx.payment_type = payload.get("payment_type", tx.payment_type)
        tx.fraud_status = payload.get("fraud_status", tx.fraud_status)
        tx.raw_response = payload
        tx.save()

        settled = tx.transaction_status in ("settlement", "capture")
        was_pending = prev_status not in ("settlement", "capture")

        if settled and tx.purpose == "wallet_topup":
            try_credit_wallet_topup(
                user=tx.user,
                gross_amount=int(tx.gross_amount),
                payment_order_id=str(tx.order_id),
            )

        if settled and was_pending and tx.purpose == "shop_order" and tx.linked_order_id:
            if try_settle_shop_order_payment(tx=tx):
                logger.info("webhook settled shop_order linked=%s", tx.linked_order_id)

        # Simpan kartu: notifikasi pertama sering tanpa saved_token_id; webhook kedua / status API
        # melengkapi. Jangan hanya mengandalkan was_pending atau blok di atas.
        if (
            settled
            and tx.purpose in ("shop_order", "wallet_topup")
            and tx.payment_method_type == "card"
            and str(tx.fraud_status or "").lower() in ("accept", "")
        ):
            payload_dict = dict(payload) if hasattr(payload, "keys") else payload
            CardChargeView._upsert_saved_card(user=tx.user, response_payload=payload_dict)

        return Response({"detail": "Notification received."}, status=status.HTTP_200_OK)


class PaymentStatusView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, order_id):
        tx = PaymentTransaction.objects.filter(order_id=order_id, user=request.user).first()
        if not tx:
            return Response({"detail": "Transaction not found."}, status=status.HTTP_404_NOT_FOUND)

        try:
            latest_status = MidtransService.get_transaction_status(order_id)
            prev_status = tx.transaction_status
            tx.transaction_status = latest_status.get("transaction_status", tx.transaction_status)
            tx.payment_type = latest_status.get("payment_type", tx.payment_type)
            tx.fraud_status = latest_status.get("fraud_status", tx.fraud_status)
            tx.raw_response = latest_status
            tx.save()

            settled = tx.transaction_status in ("settlement", "capture")
            was_pending = prev_status not in ("settlement", "capture")

            # Reconciliation fallback: credit wallet if webhook was never received
            if settled and tx.purpose == "wallet_topup":
                try_credit_wallet_topup(
                    user=tx.user,
                    gross_amount=int(tx.gross_amount),
                    payment_order_id=str(tx.order_id),
                )

            if settled and was_pending and tx.purpose == "shop_order" and tx.linked_order_id:
                if try_settle_shop_order_payment(tx=tx):
                    logger.info("status poll settled shop_order linked=%s", tx.linked_order_id)

            # Simpan kartu: polling status (sama seperti webhook) — tidak hanya saat was_pending.
            if (
                settled
                and tx.purpose in ("shop_order", "wallet_topup")
                and tx.payment_method_type == "card"
                and isinstance(latest_status, dict)
                and str(tx.fraud_status or "").lower() in ("accept", "")
            ):
                CardChargeView._upsert_saved_card(user=tx.user, response_payload=latest_status)
        except Exception:
            pass

        return Response(PaymentTransactionSerializer(tx).data)


class PaymentMethodsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        methods = [
            {
                "id": "wallet",
                "label": "Wallet",
                "description": "Pay using your Mixéra wallet balance",
            },
            {
                "id": "card",
                "label": "Credit / Debit Card",
                "description": "Pay with a card via Midtrans",
            },
        ]
        return Response({"methods": methods})


class SavedCardListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        cards = SavedCard.objects.filter(user=request.user)
        return Response(SavedCardSerializer(cards, many=True).data)


class SavedCardDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def _get_card(self, pk, user):
        try:
            return SavedCard.objects.get(pk=pk, user=user)
        except SavedCard.DoesNotExist:
            return None

    def patch(self, request, pk):
        card = self._get_card(pk, request.user)
        if not card:
            return Response({"detail": "Card not found."}, status=status.HTTP_404_NOT_FOUND)
        SavedCard.objects.filter(user=request.user, is_default=True).update(is_default=False)
        card.is_default = True
        card.save(update_fields=["is_default"])
        return Response(SavedCardSerializer(card).data)

    def delete(self, request, pk):
        card = self._get_card(pk, request.user)
        if not card:
            return Response({"detail": "Card not found."}, status=status.HTTP_404_NOT_FOUND)
        card.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
