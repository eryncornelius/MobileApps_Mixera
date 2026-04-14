import logging

import requests as http_requests
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from django.db import transaction as db_transaction

from users.models import Address
from users.notifications import notify_user
from cart.models import Cart
from sellers.services.seller_cart_service import assert_checkout_allowed
from wallet.models import Wallet, WalletTransaction
from .models import Order, OrderItem
from .serializers import OrderSerializer
from .services.checkout_shipping import validated_delivery_fee
from sellers.services.ledger_service import record_seller_earnings_for_paid_order

logger = logging.getLogger("mixera.orders")


class CheckoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        address_id = request.data.get('address_id')
        payment_method = request.data.get('payment_method')

        if not address_id or payment_method not in ('wallet', 'card'):
            return Response(
                {'detail': 'address_id and valid payment_method required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            address = Address.objects.get(pk=address_id, user=request.user)
        except Address.DoesNotExist:
            return Response({'detail': 'Address not found.'}, status=status.HTTP_404_NOT_FOUND)

        cart, _ = Cart.objects.get_or_create(user=request.user)
        items = list(
            cart.items
            .select_related('variant__product')
            .prefetch_related('variant__product__images')
        )

        if not items:
            return Response({'detail': 'Cart is empty.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            assert_checkout_allowed(cart)
        except ValueError as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        subtotal = sum(item.line_total for item in items)
        discount_total = 0
        try:
            delivery_fee = validated_delivery_fee(
                cart=cart,
                address=address,
                requested=request.data.get("delivery_fee"),
            )
        except ValueError as e:
            return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        total = subtotal + delivery_fee - discount_total

        if payment_method == 'wallet':
            wallet_check, _ = Wallet.objects.get_or_create(user=request.user)
            if wallet_check.balance < total:
                return Response(
                    {'detail': 'Insufficient wallet balance.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        try:
            with db_transaction.atomic():
                order = Order.objects.create(
                    user=request.user,
                    address=address,
                    address_snapshot={
                        'label': address.label,
                        'recipient_name': address.recipient_name,
                        'phone_number': address.phone_number,
                        'street_address': address.street_address,
                        'city': address.city,
                        'state': address.state,
                        'postal_code': address.postal_code,
                    },
                    subtotal=subtotal,
                    delivery_fee=delivery_fee,
                    discount_total=discount_total,
                    total=total,
                    payment_method=payment_method,
                    payment_status='unpaid',
                    status='pending',
                )

                for item in items:
                    product = item.variant.product
                    img = (
                        product.images.filter(is_primary=True).first()
                        or product.images.first()
                    )
                    OrderItem.objects.create(
                        order=order,
                        variant=item.variant,
                        product_name=product.name,
                        product_slug=product.slug,
                        variant_size=item.variant.size,
                        color=product.color,
                        primary_image=img.image_url if img else '',
                        unit_price=item.unit_price,
                        quantity=item.quantity,
                        line_total=item.line_total,
                    )

                if payment_method == 'wallet':
                    wallet, _ = Wallet.objects.select_for_update().get_or_create(user=request.user)
                    if wallet.balance < total:
                        raise ValueError('Insufficient wallet balance.')
                    wallet.balance -= total
                    wallet.save(update_fields=['balance', 'updated_at'])
                    WalletTransaction.objects.create(
                        wallet=wallet,
                        type='deduction',
                        amount=total,
                        reference=f"order_{order.pk}",
                        description=f"Order #{order.pk}",
                    )
                    order.payment_status = 'paid'
                    order.status = 'processing'
                    order.save(update_fields=['payment_status', 'status'])
                    record_seller_earnings_for_paid_order(order)
                    notify_user(
                        request.user, 'order',
                        'Pesanan Dikonfirmasi',
                        f'Pesanan #{order.pk} berhasil dibuat dan sedang diproses.',
                        payload={'order_id': order.pk, 'status': 'processing'},
                    )
                    logger.info("wallet checkout paid order_id=%s", order.pk)
                    # Clear cart immediately for wallet payments (paid synchronously).
                    # For card payments, cart is cleared after charge succeeds.
                    cart.items.all().delete()

        except ValueError as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        return Response(OrderSerializer(order).data, status=status.HTTP_201_CREATED)


class OrderListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        orders = Order.objects.filter(user=request.user).prefetch_related('items')
        return Response(OrderSerializer(orders, many=True).data)


class OrderDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        try:
            order = Order.objects.prefetch_related('items').get(pk=pk, user=request.user)
        except Order.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response(OrderSerializer(order).data)


class OrderTrackingView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        try:
            order = Order.objects.get(pk=pk, user=request.user)
        except Order.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        waybill = (order.tracking_number or '').strip()
        if not waybill:
            return Response(
                {'detail': 'Nomor resi belum tersedia.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        courier = (order.shipping_courier or '').strip().lower() or 'jne'
        api_key = getattr(settings, 'BITESHIP_API_KEY', '').strip()
        if not api_key:
            return Response(
                {'detail': 'Layanan tracking belum dikonfigurasi.'},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        try:
            resp = http_requests.get(
                f'https://api.biteship.com/v1/trackings/{waybill}',
                params={'couriers': courier},
                headers={
                    'Authorization': f'Bearer {api_key}',
                    'Content-Type': 'application/json',
                },
                timeout=10,
            )
            data = resp.json()
        except Exception as e:
            logger.exception("Biteship tracking error order_id=%s", pk)
            return Response(
                {'detail': 'Gagal menghubungi layanan tracking.'},
                status=status.HTTP_502_BAD_GATEWAY,
            )

        if not data.get('success'):
            return Response(
                {'detail': data.get('error', 'Tracking tidak ditemukan.')},
                status=status.HTTP_404_NOT_FOUND,
            )

        obj = data.get('object', {})
        history = [
            {
                'status': h.get('status', ''),
                'note': h.get('note', ''),
                'updated_time': h.get('updated_time', ''),
            }
            for h in (obj.get('history') or [])
        ]

        return Response({
            'waybill': waybill,
            'courier': courier,
            'status': obj.get('status', ''),
            'history': history,
        })
