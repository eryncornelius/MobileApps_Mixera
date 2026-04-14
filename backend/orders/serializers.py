from rest_framework import serializers

from .models import Order, OrderItem


class OrderItemSerializer(serializers.ModelSerializer):
    variant_id = serializers.IntegerField(read_only=True)

    class Meta:
        model = OrderItem
        fields = (
            'id',
            'variant_id',
            'product_name',
            'product_slug',
            'variant_size',
            'color',
            'primary_image',
            'unit_price',
            'quantity',
            'line_total',
        )


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)

    class Meta:
        model = Order
        fields = (
            'id',
            'status',
            'subtotal',
            'delivery_fee',
            'discount_total',
            'total',
            'payment_method',
            'payment_status',
            'tracking_number',
            'shipping_courier',
            'address_snapshot',
            'created_at',
            'items',
        )
