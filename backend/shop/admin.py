from django.contrib import admin
from .models import Product, RecentSearch, RecentlyViewed


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'price')
    list_filter = ('category',)
    search_fields = ('name',)


@admin.register(RecentSearch)
class RecentSearchAdmin(admin.ModelAdmin):
    list_display = ('user', 'query', 'created_at')
    search_fields = ('query', 'user__email')
    ordering = ('-created_at',)


@admin.register(RecentlyViewed)
class RecentlyViewedAdmin(admin.ModelAdmin):
    list_display = ('user', 'product', 'created_at')
    search_fields = ('user__email', 'product__name')
    ordering = ('-created_at',)
