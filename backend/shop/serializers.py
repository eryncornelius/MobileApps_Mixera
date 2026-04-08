from rest_framework import serializers
from .models import Product, RecentSearch, RecentlyViewed


class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = ['id', 'name', 'price', 'category', 'image_url']


class RecentSearchSerializer(serializers.ModelSerializer):
    class Meta:
        model = RecentSearch
        fields = ['id', 'query', 'created_at']


class RecentlyViewedSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    product_id = serializers.PrimaryKeyRelatedField(
        queryset=Product.objects.all(), source='product', write_only=True
    )

    class Meta:
        model = RecentlyViewed
        fields = ['id', 'product', 'product_id', 'created_at']
