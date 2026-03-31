from django.conf import settings
from django.db import models


class Wallet(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='wallet',
    )
    balance = models.PositiveIntegerField(default=0)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.email} - Rp {self.balance}"


class WalletTransaction(models.Model):
    TYPE_CHOICES = (
        ('top_up', 'Top Up'),
        ('deduction', 'Deduction'),
    )

    wallet = models.ForeignKey(
        Wallet,
        on_delete=models.CASCADE,
        related_name='transactions',
    )
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    amount = models.PositiveIntegerField()
    reference = models.CharField(max_length=100, blank=True, null=True)  # order_id
    description = models.CharField(max_length=255, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.wallet.user.email} - {self.type} - Rp {self.amount}"
