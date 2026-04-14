from rest_framework import serializers

from orders.models import Order, OrderItem
from orders.serializers import OrderItemSerializer
from shop.models import Category, Product, ProductImage, ProductVariant
from .models import (
    SellerChannelListing,
    SellerNotification,
    SellerOrderEarning,
    SellerPayoutRequest,
    SellerProfile,
)


class SellerProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = SellerProfile
        fields = ("store_name", "ship_from_postal_code", "updated_at")
        read_only_fields = ("updated_at",)


class SellerMeSerializer(serializers.Serializer):
    store_name = serializers.CharField(max_length=120, required=False, allow_blank=True)
    ship_from_postal_code = serializers.CharField(
        max_length=10, required=False, allow_blank=True
    )

    def validate_ship_from_postal_code(self, value):
        v = (value or "").strip()
        if not v:
            return ""
        digits = "".join(ch for ch in v if ch.isdigit())
        if len(digits) < 5:
            raise serializers.ValidationError("Kode pos asal pengiriman harus 5 digit.")
        return digits[:5]


class VariantRowWriteSerializer(serializers.Serializer):
    size = serializers.ChoiceField(choices=ProductVariant.SIZE_CHOICES)
    stock = serializers.IntegerField(min_value=0, default=0)


class SellerProductWriteSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=200)
    description = serializers.CharField(required=False, allow_blank=True, default="")
    price = serializers.IntegerField(min_value=0)
    discount_price = serializers.IntegerField(required=False, allow_null=True, min_value=0)
    color = serializers.CharField(required=False, allow_blank=True, default="")
    category_id = serializers.IntegerField(required=False, allow_null=True)
    stock = serializers.IntegerField(min_value=0, default=0)
    size = serializers.ChoiceField(choices=ProductVariant.SIZE_CHOICES, default="M")
    image_url = serializers.URLField(required=False, allow_blank=True, default="")
    variants = VariantRowWriteSerializer(many=True, required=False, allow_null=True)


class VariantStockRowSerializer(serializers.Serializer):
    variant_id = serializers.IntegerField(min_value=1)
    stock = serializers.IntegerField(min_value=0)


class SellerProductPatchSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=200, required=False)
    description = serializers.CharField(required=False, allow_blank=True)
    price = serializers.IntegerField(required=False, min_value=0)
    discount_price = serializers.IntegerField(required=False, allow_null=True, min_value=0)
    color = serializers.CharField(required=False, allow_blank=True)
    is_active = serializers.BooleanField(required=False)
    stock = serializers.IntegerField(required=False, min_value=0)
    image_url = serializers.URLField(required=False, allow_blank=True, max_length=500)
    variant_stocks = VariantStockRowSerializer(many=True, required=False)
    variants_add = VariantRowWriteSerializer(many=True, required=False)


class SellerProductImageUploadSerializer(serializers.Serializer):
    image = serializers.ImageField(allow_empty_file=False)

    def validate_image(self, value):
        max_bytes = 5 * 1024 * 1024
        if value.size > max_bytes:
            raise serializers.ValidationError("File terlalu besar (maks 5 MB).")
        return value


class SellerOrderUpdateSerializer(serializers.Serializer):
    tracking_number = serializers.CharField(max_length=120, required=False, allow_blank=True)
    shipping_courier = serializers.CharField(max_length=80, required=False, allow_blank=True)
    status = serializers.ChoiceField(
        choices=["processing", "shipped", "completed"],
        required=False,
    )


class SellerOrderListSerializer(serializers.ModelSerializer):
    buyer_email = serializers.EmailField(source="user.email", read_only=True)
    item_count = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = (
            "id",
            "status",
            "payment_status",
            "total",
            "tracking_number",
            "shipping_courier",
            "created_at",
            "buyer_email",
            "item_count",
        )

    def get_item_count(self, obj):
        return obj.items.filter(variant__product__seller=self.context["seller"]).count()


class SellerOrderDetailSerializer(serializers.ModelSerializer):
    buyer_email = serializers.EmailField(source="user.email", read_only=True)
    items = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = (
            "id",
            "status",
            "payment_status",
            "subtotal",
            "delivery_fee",
            "discount_total",
            "total",
            "tracking_number",
            "shipping_courier",
            "address_snapshot",
            "created_at",
            "buyer_email",
            "items",
        )

    def get_items(self, obj):
        seller = self.context["seller"]
        qs = obj.items.filter(variant__product__seller=seller).select_related("variant__product")
        return OrderItemSerializer(qs, many=True).data


class SellerOrderEarningSerializer(serializers.ModelSerializer):
    class Meta:
        model = SellerOrderEarning
        fields = (
            "id",
            "order",
            "item_subtotal_gross",
            "platform_fee",
            "net_to_seller",
            "created_at",
        )


class SellerPayoutSerializer(serializers.ModelSerializer):
    class Meta:
        model = SellerPayoutRequest
        fields = ("id", "amount", "status", "admin_note", "created_at", "processed_at")


class SellerPayoutCreateSerializer(serializers.Serializer):
    amount = serializers.IntegerField(min_value=1)


class SellerNotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = SellerNotification
        fields = ("id", "title", "body", "is_read", "created_at")


class SellerChannelListingSerializer(serializers.ModelSerializer):
    class Meta:
        model = SellerChannelListing
        fields = (
            "id",
            "product",
            "channel",
            "external_id",
            "sync_status",
            "last_error",
            "updated_at",
        )


class SellerChannelCreateSerializer(serializers.Serializer):
    product_id = serializers.IntegerField(min_value=1)
    channel = serializers.ChoiceField(choices=SellerChannelListing.Channel.choices)


class ShippingQuoteSerializer(serializers.Serializer):
    weight_grams = serializers.IntegerField(min_value=0, default=500)
    destination_city = serializers.CharField(required=False, allow_blank=True, default="")
    destination_postal_code = serializers.CharField(required=False, allow_blank=True, default="", max_length=10)
