from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from shop.models import ProductVariant
from .models import Cart, CartItem
from .serializers import CartItemDetailSerializer


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
