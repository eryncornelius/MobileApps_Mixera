from django.contrib import admin

from .models import Order, OrderItem


class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0
    readonly_fields = ('product_name', 'variant_size', 'unit_price', 'quantity', 'line_total')


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'status', 'payment_method', 'payment_status', 'total', 'created_at')
    list_filter = ('status', 'payment_method', 'payment_status')
    search_fields = ('user__email',)
    readonly_fields = ('created_at', 'updated_at', 'address_snapshot')
    inlines = [OrderItemInline]
