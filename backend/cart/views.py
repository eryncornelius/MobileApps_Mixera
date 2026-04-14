import re

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from shop.models import ProductVariant
from sellers.services.seller_cart_service import assert_checkout_allowed, can_add_variant
from sellers.services.shipping_origin import origin_postal_for_cart
from sellers.services.shipping_rates import resolve_shipping_quotes
from users.models import Address

from .models import Cart, CartItem
from .serializers import CartItemDetailSerializer, CartShippingQuoteSerializer
from .services.cart_weight import estimated_cart_weight_grams


class CartView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        cart, _ = Cart.objects.get_or_create(user=request.user)
        items = cart.items.select_related('variant__product').prefetch_related('variant__product__images')
        serializer = CartItemDetailSerializer(items, many=True)
        total = sum(item.line_total for item in items)
        return Response({'items': serializer.data, 'total': total, 'count': items.count()})


class CartItemView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        variant_id = request.data.get('variant_id')
        quantity = request.data.get('quantity', 1)

        if not variant_id:
            return Response({'detail': 'variant_id required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            quantity = int(quantity)
            if quantity < 1:
                raise ValueError
        except (ValueError, TypeError):
            return Response({'detail': 'Valid quantity required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            variant = ProductVariant.objects.select_related('product').get(pk=variant_id)
        except ProductVariant.DoesNotExist:
            return Response({'detail': 'Variant not found.'}, status=status.HTTP_404_NOT_FOUND)

        cart, _ = Cart.objects.get_or_create(user=request.user)
        ok, err = can_add_variant(cart, variant.product)
        if not ok:
            return Response({'detail': err}, status=status.HTTP_400_BAD_REQUEST)

        unit_price = variant.product.discount_price or variant.product.price

        item, created = CartItem.objects.get_or_create(
            cart=cart,
            variant=variant,
            defaults={'unit_price': unit_price, 'quantity': quantity},
        )
        if not created:
            item.quantity += quantity
            item.save(update_fields=['quantity'])

        http_status = status.HTTP_201_CREATED if created else status.HTTP_200_OK
        return Response(CartItemDetailSerializer(item).data, status=http_status)

    def patch(self, request, pk):
        cart, _ = Cart.objects.get_or_create(user=request.user)
        try:
            item = CartItem.objects.get(pk=pk, cart=cart)
        except CartItem.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            quantity = int(request.data.get('quantity'))
            if quantity < 1:
                raise ValueError
        except (ValueError, TypeError):
            return Response({'detail': 'Valid quantity required.'}, status=status.HTTP_400_BAD_REQUEST)

        item.quantity = quantity
        item.save(update_fields=['quantity'])
        return Response(CartItemDetailSerializer(item).data)

    def delete(self, request, pk):
        cart, _ = Cart.objects.get_or_create(user=request.user)
        CartItem.objects.filter(pk=pk, cart=cart).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class ClearCartView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request):
        cart, _ = Cart.objects.get_or_create(user=request.user)
        cart.items.all().delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class CartShippingQuoteView(APIView):
    """
    Perkiraan ongkir ke alamat pembeli (Biteship jika dikonfigurasi + kode pos valid),
    berat dari estimasi per qty keranjang.
    """

    permission_classes = [IsAuthenticated]

    def post(self, request):
        ser = CartShippingQuoteSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        d = ser.validated_data

        dest_pc = (d.get("destination_postal_code") or "").strip().replace(" ", "")
        aid = d.get("address_id")
        if aid is not None:
            addr = Address.objects.filter(pk=aid, user=request.user).first()
            if not addr:
                return Response({"detail": "Alamat tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)
            raw_pc = re.sub(r"\D", "", addr.postal_code or "")
            dest_pc = raw_pc[:5] if len(raw_pc) >= 5 else ""

        cart, _ = Cart.objects.get_or_create(user=request.user)
        if not cart.items.exists():
            return Response({"detail": "Keranjang kosong."}, status=status.HTTP_400_BAD_REQUEST)
        try:
            assert_checkout_allowed(cart)
        except ValueError as e:
            return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)

        weight = estimated_cart_weight_grams(cart)
        origin_pc = origin_postal_for_cart(cart)
        quotes, note = resolve_shipping_quotes(
            weight_grams=weight,
            destination_city="",
            destination_postal_code=dest_pc,
            origin_postal_code=origin_pc,
        )
        cheapest = None
        if quotes:
            cheapest = min(int(q.get("price", 0) or 0) for q in quotes)
        return Response(
            {
                "quotes": quotes,
                "note": note,
                "estimated_weight_grams": weight,
                "cheapest_price": cheapest,
            }
        )
