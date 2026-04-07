from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from django.db import transaction as db_transaction

from users.models import Address
from cart.models import Cart
from wallet.models import Wallet, WalletTransaction
from .models import Order, OrderItem
from .serializers import OrderSerializer

DELIVERY_FEE = 20000


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

        subtotal = sum(item.line_total for item in items)
        discount_total = 0
        delivery_fee = DELIVERY_FEE
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
