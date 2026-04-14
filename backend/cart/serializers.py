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


class CartShippingQuoteSerializer(serializers.Serializer):
    """Salah satu: alamat tersimpan (kode pos dari situ) atau kode pos manual."""

    destination_postal_code = serializers.CharField(required=False, allow_blank=True, max_length=20)
    address_id = serializers.IntegerField(required=False, allow_null=True, min_value=1)

    def validate(self, attrs):
        aid = attrs.get("address_id")
        raw = (attrs.get("destination_postal_code") or "").strip().replace(" ", "")
        if aid is not None:
            return attrs
        if not raw or not raw.isdigit() or len(raw) < 5:
            raise serializers.ValidationError(
                {"detail": "Kirim address_id (alamat tersimpan) atau destination_postal_code (min. 5 digit)."}
            )
        return attrs
