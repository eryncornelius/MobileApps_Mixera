from django.conf import settings
from django.db import models


class PaymentTransaction(models.Model):
    STATUS_CHOICES = (
        ("pending", "Pending"),
        ("settlement", "Settlement"),
        ("capture", "Capture"),
        ("deny", "Deny"),
        ("cancel", "Cancel"),
        ("expire", "Expire"),
        ("failure", "Failure"),
        ("refund", "Refund"),
        ("partial_refund", "Partial Refund"),
    )

    PURPOSE_CHOICES = (
        ("wallet_topup", "Wallet Top Up"),
        ("shop_order", "Shop Order"),
    )

    PAYMENT_METHOD_TYPE_CHOICES = (
        ("snap", "Snap"),
        ("card", "Card"),
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="payment_transactions",
    )
    order_id = models.CharField(max_length=100, unique=True)
    purpose = models.CharField(max_length=30, choices=PURPOSE_CHOICES)
    payment_method_type = models.CharField(
        max_length=20,
        choices=PAYMENT_METHOD_TYPE_CHOICES,
        blank=True,
        null=True,
    )
    gross_amount = models.PositiveIntegerField()
    payment_type = models.CharField(max_length=50, blank=True, null=True)
    transaction_status = models.CharField(
        max_length=30,
        choices=STATUS_CHOICES,
        default="pending",
    )
    fraud_status = models.CharField(max_length=30, blank=True, null=True)
    snap_token = models.CharField(max_length=255, blank=True, null=True)
    redirect_url = models.URLField(blank=True, null=True)
    linked_order_id = models.PositiveIntegerField(null=True, blank=True)
    raw_response = models.JSONField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.order_id} - {self.transaction_status}"


class SavedCard(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="saved_cards",
    )
    card_brand = models.CharField(max_length=50, blank=True)
    masked_card = models.CharField(max_length=20, blank=True)
    saved_token_id = models.CharField(max_length=255, unique=True)
    expiry_month = models.CharField(max_length=2, blank=True)
    expiry_year = models.CharField(max_length=4, blank=True)
    card_type = models.CharField(max_length=30, blank=True)
    is_default = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.user} - {self.card_brand} {self.masked_card}"
