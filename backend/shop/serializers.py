from rest_framework import serializers

from .models import Category, Product, ProductImage, ProductVariant


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ('id', 'name', 'slug')


class ProductImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductImage
        fields = ('id', 'image_url', 'is_primary')


class ProductVariantSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductVariant
        fields = ('id', 'size', 'stock', 'sku')


class ProductListSerializer(serializers.ModelSerializer):
    primary_image = serializers.SerializerMethodField()
    category_name = serializers.CharField(source='category.name', read_only=True)
    category_slug = serializers.CharField(source='category.slug', read_only=True)
    total_stock = serializers.SerializerMethodField()
    is_wishlisted = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = (
            'id',
            'name',
            'slug',
            'price',
            'discount_price',
            'category_name',
            'category_slug',
            'color',
            'is_new',
            'is_active',
            'moderation_flagged',
            'moderation_note',
            'total_stock',
            'primary_image',
            'is_wishlisted',
        )

    def get_primary_image(self, obj):
        img = obj.images.filter(is_primary=True).first() or obj.images.first()
        return img.image_url if img else None

    def get_total_stock(self, obj):
        return sum(v.stock for v in obj.variants.all())

    def get_is_wishlisted(self, obj):
        request = self.context.get("request")
        user = getattr(request, "user", None)
        if not user or not user.is_authenticated:
            return False
        return obj.wishlist_items.filter(user=user).exists()


class ProductDetailSerializer(serializers.ModelSerializer):
    images = ProductImageSerializer(many=True, read_only=True)
    variants = ProductVariantSerializer(many=True, read_only=True)
    category = CategorySerializer(read_only=True)
    seller_id = serializers.IntegerField(source="seller.id", read_only=True)
    seller_phone = serializers.SerializerMethodField()
    seller_store_name = serializers.SerializerMethodField()
    is_wishlisted = serializers.SerializerMethodField()

    def get_seller_phone(self, obj):
        seller = getattr(obj, "seller", None)
        return (getattr(seller, "phone_number", "") or "").strip()

    def get_seller_store_name(self, obj):
        seller = getattr(obj, "seller", None)
        if not seller:
            return ""
        profile = getattr(seller, "seller_profile", None)
        if profile and profile.store_name:
            return profile.store_name
        return seller.username or ""

    def get_is_wishlisted(self, obj):
        request = self.context.get("request")
        user = getattr(request, "user", None)
        if not user or not user.is_authenticated:
            return False
        return obj.wishlist_items.filter(user=user).exists()

    class Meta:
        model = Product
        fields = (
            'id',
            'name',
            'slug',
            'description',
            'price',
            'discount_price',
            'category',
            'color',
            'is_new',
            'is_active',
            'moderation_flagged',
            'moderation_note',
            'seller_id',
            'seller_store_name',
            'seller_phone',
            'is_wishlisted',
            'images',
            'variants',
            'created_at',
        )
