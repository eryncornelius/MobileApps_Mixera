from django.db import models
from django.conf import settings

from shop.models import ProductVariant


class Cart(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='cart'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Cart({self.user})"


class CartItem(models.Model):
    cart = models.ForeignKey(Cart, on_delete=models.CASCADE, related_name='items')
    variant = models.ForeignKey(ProductVariant, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)
    unit_price = models.PositiveIntegerField()

    class Meta:
        unique_together = ('cart', 'variant')

    def __str__(self):
        return f"{self.variant} x{self.quantity}"

    @property
    def line_total(self):
        return self.unit_price * self.quantity
