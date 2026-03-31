from rest_framework import serializers

from .models import Order, OrderItem


class OrderItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderItem
        fields = (
            'id', 'product_name', 'product_slug', 'variant_size',
            'color', 'primary_image', 'unit_price', 'quantity', 'line_total',
        )


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)

    class Meta:
        model = Order
        fields = (
            'id', 'status', 'subtotal', 'delivery_fee', 'discount_total', 'total',
            'payment_method', 'payment_status', 'address_snapshot', 'created_at', 'items',
        )
