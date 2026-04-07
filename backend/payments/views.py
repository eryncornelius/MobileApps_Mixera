import hashlib
import uuid

from django.conf import settings
from django.db import transaction as db_transaction
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from wallet.models import WalletTransaction
from wallet.services import credit_wallet

from .models import PaymentTransaction, SavedCard
from .serializers import (
    CardChargeSerializer,
    CreateSnapTransactionSerializer,
    PaymentTransactionSerializer,
    SavedCardSerializer,
)
from .services import MidtransService


class CreateSnapTransactionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = CreateSnapTransactionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

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
    Core API card charge for shop orders.
    Frontend obtains a one-time card_token via Midtrans.js,
    or supplies a saved_token_id from a previously saved card.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = CardChargeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        django_order_id = serializer.validated_data["django_order_id"]
        card_token = serializer.validated_data.get("card_token", "")
        saved_card_id = serializer.validated_data.get("saved_card_id")
        save_card = serializer.validated_data["save_card"]

        # Resolve which token to send to Midtrans
        if saved_card_id:
            try:
                saved_card_obj = SavedCard.objects.get(pk=saved_card_id, user=request.user)
                token_to_charge = saved_card_obj.saved_token_id
            except SavedCard.DoesNotExist:
                return Response({"detail": "Saved card not found."}, status=status.HTTP_404_NOT_FOUND)
        else:
            token_to_charge = card_token

        from orders.models import Order
        try:
            order = Order.objects.get(pk=django_order_id, user=request.user)
        except Order.DoesNotExist:
            return Response({"detail": "Order not found."}, status=status.HTTP_404_NOT_FOUND)

        if order.payment_status == "paid":
            return Response({"detail": "Order already paid."}, status=status.HTTP_400_BAD_REQUEST)

        midtrans_order_id = f"MXR-ORD-{django_order_id}-{uuid.uuid4().hex[:8].upper()}"

        payload = {
            "payment_type": "credit_card",
            "transaction_details": {
                "order_id": midtrans_order_id,
                "gross_amount": order.total,
            },
            "credit_card": {
                "token_id": token_to_charge,
                "authentication": True,
                "save_card": save_card,
            },
            "customer_details": {
                "first_name": request.user.username,
                "email": request.user.email,
                "phone": request.user.phone_number or "",
            },
        }

        if settings.MIDTRANS_NOTIFICATION_URL:
            payload["notification_url"] = settings.MIDTRANS_NOTIFICATION_URL

        # After 3DS the browser redirects to this URL. The Flutter WebView
        # intercepts it (non-Midtrans domain) and starts polling for status.
        payload["callbacks"] = {"finish": "mixera://3ds/done"}

        # Idempotency — reuse existing pending tx for this order if charge failed mid-flight
        existing_tx = PaymentTransaction.objects.filter(
            linked_order_id=django_order_id,
            user=request.user,
            purpose="shop_order",
            transaction_status="pending",
        ).first()
        if existing_tx:
            return Response(PaymentTransactionSerializer(existing_tx).data, status=status.HTTP_200_OK)

        try:
            midtrans_response = MidtransService.charge_card(payload)

        except Exception as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_502_BAD_GATEWAY)

        tx_status = midtrans_response.get("transaction_status", "pending")
        fraud = midtrans_response.get("fraud_status")

        tx = PaymentTransaction.objects.create(
            user=request.user,
            order_id=midtrans_order_id,
            purpose="shop_order",
            payment_method_type="card",
            gross_amount=order.total,
            transaction_status=tx_status,
            fraud_status=fraud,
            payment_type=midtrans_response.get("payment_type"),
            linked_order_id=django_order_id,
            redirect_url=midtrans_response.get("redirect_url"),
            raw_response=midtrans_response,
        )

        # Mark order paid immediately on capture/settlement with no fraud flag
        if tx_status in ("capture", "settlement") and fraud in ("accept", None, ""):
            from cart.models import Cart
            with db_transaction.atomic():
                order.payment_status = "paid"
                order.status = "processing"
                order.save(update_fields=["payment_status", "status"])
                cart = Cart.objects.filter(user=request.user).first()
                if cart:
                    cart.items.all().delete()

        # Store saved card if Midtrans returned a token
        if save_card:
            new_token = midtrans_response.get("saved_token_id")
            masked = midtrans_response.get("masked_card", "")
            brand = midtrans_response.get("bank", "")
            if new_token and not SavedCard.objects.filter(saved_token_id=new_token).exists():
                is_first = not SavedCard.objects.filter(user=request.user).exists()
                SavedCard.objects.create(
                    user=request.user,
                    card_brand=brand,
                    masked_card=masked,
                    saved_token_id=new_token,
                    is_default=is_first,
                )

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

        if settled and was_pending:
            if tx.purpose == "wallet_topup":
                credit_wallet(
                    user=tx.user,
                    amount=tx.gross_amount,
                    reference=tx.order_id,
                )
            elif tx.purpose == "shop_order" and tx.linked_order_id:
                from orders.models import Order
                from cart.models import Cart
                fraud = tx.fraud_status
                if fraud in ("accept", None, ""):
                    Order.objects.filter(
                        pk=tx.linked_order_id,
                        user=tx.user,
                        payment_status="unpaid",
                    ).update(payment_status="paid", status="processing")
                    cart = Cart.objects.filter(user=tx.user).first()
                    if cart:
                        cart.items.all().delete()

                # For 3DS card transactions the initial charge response is
                # "pending", so saved_token_id only arrives here in the webhook.
                if tx.payment_method_type == "card":
                    saved_token_id = payload.get("saved_token_id")
                    if saved_token_id and not SavedCard.objects.filter(
                        saved_token_id=saved_token_id
                    ).exists():
                        is_first = not SavedCard.objects.filter(user=tx.user).exists()
                        SavedCard.objects.create(
                            user=tx.user,
                            card_brand=payload.get("bank", ""),
                            masked_card=payload.get("masked_card", ""),
                            saved_token_id=saved_token_id,
                            is_default=is_first,
                        )

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
            if settled and was_pending and tx.purpose == "wallet_topup":
                already_credited = WalletTransaction.objects.filter(
                    reference=tx.order_id
                ).exists()
                if not already_credited:
                    credit_wallet(
                        user=tx.user,
                        amount=tx.gross_amount,
                        reference=tx.order_id,
                    )

            # Reconciliation fallback: save card if webhook was never received.
            # Midtrans returns saved_token_id in the status poll response too.
            if settled and was_pending and tx.payment_method_type == "card":
                saved_token_id = latest_status.get("saved_token_id")
                if saved_token_id and not SavedCard.objects.filter(
                    saved_token_id=saved_token_id
                ).exists():
                    is_first = not SavedCard.objects.filter(user=tx.user).exists()
                    SavedCard.objects.create(
                        user=tx.user,
                        card_brand=latest_status.get("bank", ""),
                        masked_card=latest_status.get("masked_card", ""),
                        saved_token_id=saved_token_id,
                        is_default=is_first,
                    )
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
