from django.contrib import admin
from django.utils import timezone

from .models import (
    SellerChannelListing,
    SellerNotification,
    SellerOrderEarning,
    SellerPayoutRequest,
    SellerProfile,
)


@admin.register(SellerProfile)
class SellerProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "store_name", "updated_at")
    search_fields = ("user__email", "store_name")


@admin.register(SellerOrderEarning)
class SellerOrderEarningAdmin(admin.ModelAdmin):
    list_display = ("order", "seller", "item_subtotal_gross", "platform_fee", "net_to_seller", "created_at")
    list_filter = ("created_at",)
    search_fields = ("seller__email",)
    readonly_fields = ("order", "seller", "item_subtotal_gross", "platform_fee", "net_to_seller", "created_at")


@admin.register(SellerPayoutRequest)
class SellerPayoutRequestAdmin(admin.ModelAdmin):
    list_display = ("seller", "amount", "status", "created_at", "processed_at")
    list_filter = ("status",)
    search_fields = ("seller__email",)
    actions = ("mark_paid",)

    @admin.action(description="Tandai payout terpilih sebagai paid")
    def mark_paid(self, request, queryset):
        queryset.update(status=SellerPayoutRequest.Status.PAID, processed_at=timezone.now())


@admin.register(SellerNotification)
class SellerNotificationAdmin(admin.ModelAdmin):
    list_display = ("seller", "title", "is_read", "created_at")
    list_filter = ("is_read",)
    search_fields = ("seller__email", "title")


@admin.register(SellerChannelListing)
class SellerChannelListingAdmin(admin.ModelAdmin):
    list_display = ("seller", "product", "channel", "sync_status", "updated_at")
    list_filter = ("channel", "sync_status")
