from rest_framework import serializers

from .models import CartItem


class CartItemDetailSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='variant.product.name', read_only=True)
    product_slug = serializers.CharField(source='variant.product.slug', read_only=True)
    size = serializers.CharField(source='variant.size', read_only=True)
    color = serializers.CharField(source='variant.product.color', read_only=True)
    primary_image = serializers.SerializerMethodField()
    line_total = serializers.IntegerField(read_only=True)

    class Meta:
        model = CartItem
        fields = (
            'id', 'variant', 'product_name', 'product_slug',
            'size', 'color', 'primary_image', 'quantity', 'unit_price', 'line_total',
        )

    def get_primary_image(self, obj):
        img = (
            obj.variant.product.images.filter(is_primary=True).first()
            or obj.variant.product.images.first()
        )
        return img.image_url if img else None
