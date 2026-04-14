from django.db import models
from django.conf import settings

from shop.models import ProductVariant
from users.models import Address


class Order(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('paid', 'Paid'),
        ('processing', 'Processing'),
        ('shipped', 'Shipped'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]
    PAYMENT_METHOD_CHOICES = [
        ('wallet', 'Wallet'),
        ('card', 'Card'),
    ]
    PAYMENT_STATUS_CHOICES = [
        ('unpaid', 'Unpaid'),
        ('paid', 'Paid'),
        ('refunded', 'Refunded'),
    ]

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='orders'
    )
    address = models.ForeignKey(Address, on_delete=models.SET_NULL, null=True, blank=True)
    address_snapshot = models.JSONField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    subtotal = models.PositiveIntegerField()
    delivery_fee = models.PositiveIntegerField(default=20000)
    discount_total = models.PositiveIntegerField(default=0)
    total = models.PositiveIntegerField()
    payment_method = models.CharField(max_length=20, choices=PAYMENT_METHOD_CHOICES)
    payment_status = models.CharField(max_length=20, choices=PAYMENT_STATUS_CHOICES, default='unpaid')
    tracking_number = models.CharField(max_length=120, blank=True)
    shipping_courier = models.CharField(max_length=80, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Order#{self.pk} - {self.user} - {self.status}"


class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    variant = models.ForeignKey(
        ProductVariant,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="order_items",
    )
    product_name = models.CharField(max_length=200)
    product_slug = models.CharField(max_length=200, blank=True)
    variant_size = models.CharField(max_length=10, blank=True)
    color = models.CharField(max_length=50, blank=True)
    primary_image = models.URLField(max_length=500, blank=True)
    unit_price = models.PositiveIntegerField()
    quantity = models.PositiveIntegerField()
    line_total = models.PositiveIntegerField()

    def __str__(self):
        return f"{self.product_name} x{self.quantity}"
