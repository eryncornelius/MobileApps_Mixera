from django.contrib import admin

from .models import Wallet, WalletTransaction


@admin.register(Wallet)
class WalletAdmin(admin.ModelAdmin):
    list_display = ('user', 'balance', 'updated_at')
    search_fields = ('user__email',)
    readonly_fields = ('updated_at',)
    ordering = ('-updated_at',)


@admin.register(WalletTransaction)
class WalletTransactionAdmin(admin.ModelAdmin):
    list_display = ('wallet', 'type', 'amount', 'reference', 'description', 'created_at')
    list_filter = ('type',)
    search_fields = ('wallet__user__email', 'reference')
    readonly_fields = ('created_at',)
    ordering = ('-created_at',)
