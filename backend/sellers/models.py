from django.conf import settings
from django.db import models


class SellerProfile(models.Model):
    """Toko / profil penjual; dibuat saat seller pertama kali update dashboard."""

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="seller_profile",
    )
    store_name = models.CharField(max_length=120, blank=True)
    # Kode pos asal pengiriman (Indonesia 5 digit) untuk quote Biteship / checkout.
    ship_from_postal_code = models.CharField(max_length=10, blank=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.email} — {self.store_name or 'Seller'}"


class SellerOrderEarning(models.Model):
    """Satu baris per seller per order (setelah pembayaran lunas)."""

    order = models.ForeignKey(
        "orders.Order",
        on_delete=models.CASCADE,
        related_name="seller_earnings",
    )
    seller = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="order_earnings",
    )
    item_subtotal_gross = models.PositiveIntegerField()
    platform_fee = models.PositiveIntegerField()
    net_to_seller = models.PositiveIntegerField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=("order", "seller"),
                name="uniq_seller_order_earning",
            ),
        ]

    def __str__(self):
        return f"Earn order#{self.order_id} seller#{self.seller_id}"


class SellerPayoutRequest(models.Model):
    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        PAID = "paid", "Paid"
        REJECTED = "rejected", "Rejected"

    seller = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="payout_requests",
    )
    amount = models.PositiveIntegerField()
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.PENDING,
    )
    admin_note = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    processed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"Payout {self.seller_id} {self.amount} {self.status}"


class SellerNotification(models.Model):
    seller = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="seller_notifications",
    )
    title = models.CharField(max_length=120)
    body = models.TextField(blank=True)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return self.title


class SellerChannelListing(models.Model):
    """Stub integrasi marketplace eksternal (Tokopedia, dll.)."""

    class Channel(models.TextChoices):
        TOKOPEDIA = "tokopedia", "Tokopedia"
        SHOPEE = "shopee", "Shopee"
        OTHER = "other", "Other"

    class SyncStatus(models.TextChoices):
        IDLE = "idle", "Idle"
        PENDING = "pending", "Pending"
        SYNCED = "synced", "Synced"
        ERROR = "error", "Error"

    seller = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="channel_listings",
    )
    product = models.ForeignKey(
        "shop.Product",
        on_delete=models.CASCADE,
        related_name="channel_listings",
    )
    channel = models.CharField(max_length=32, choices=Channel.choices)
    external_id = models.CharField(max_length=120, blank=True)
    sync_status = models.CharField(
        max_length=20,
        choices=SyncStatus.choices,
        default=SyncStatus.PENDING,
    )
    last_error = models.CharField(max_length=255, blank=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=("seller", "product", "channel"),
                name="uniq_seller_product_channel",
            ),
        ]

    def __str__(self):
        return f"{self.channel} #{self.product_id}"
