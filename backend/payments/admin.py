from django.contrib import admin

from .models import PaymentTransaction, SavedCard


@admin.register(PaymentTransaction)
class PaymentTransactionAdmin(admin.ModelAdmin):
    list_display = (
        "order_id",
        "user",
        "purpose",
        "payment_method_type",
        "gross_amount",
        "transaction_status",
        "payment_type",
        "fraud_status",
        "linked_order_id",
        "created_at",
        "updated_at",
    )
    list_filter = ("transaction_status", "purpose", "payment_method_type", "payment_type")
    search_fields = ("order_id", "user__email")
    readonly_fields = ("raw_response", "created_at", "updated_at")
    ordering = ("-created_at",)


@admin.register(SavedCard)
class SavedCardAdmin(admin.ModelAdmin):
    list_display = ("user", "card_brand", "masked_card", "is_default", "created_at")
    list_filter = ("is_default", "card_brand")
    search_fields = ("user__email", "masked_card")
    readonly_fields = ("saved_token_id", "created_at")
    ordering = ("-created_at",)
