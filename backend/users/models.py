from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone
from django.conf import settings
from datetime import timedelta
import random


class User(AbstractUser):
    AUTH_PROVIDER_CHOICES = (
        ('email', 'Email'),
        ('google', 'Google'),
        ('facebook', 'Facebook'),
    )
    email = models.EmailField(unique=True)
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    auth_provider = models.CharField(
        max_length=20,
        choices=AUTH_PROVIDER_CHOICES,
        default='email'
    )
    google_id = models.CharField(max_length=255, blank=True, null=True)
    facebook_id = models.CharField(max_length=255, blank=True, null=True)
    is_email_verified = models.BooleanField(default=False)

    ai_tokens = models.IntegerField(default=5)
    is_premium = models.BooleanField(default=False)
    premium_until = models.DateTimeField(null=True, blank=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    def __str__(self):
        return self.email


class OTPVerification(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='otp_codes'
    )
    code = models.CharField(max_length=4)
    created_at = models.DateTimeField(auto_now_add=True)
    is_used = models.BooleanField(default=False)

    def is_still_valid(self):
        expiration_time = self.created_at + timedelta(minutes=5)
        return (not self.is_used) and (timezone.now() <= expiration_time)

    @classmethod
    def generate_otp(cls, user):
        cls.objects.filter(user=user, is_used=False).update(is_used=True)
        code = str(random.randint(1000, 9999))
        return cls.objects.create(user=user, code=code)

    def __str__(self):
        return f"{self.user.email} - {self.code}"
    

class Address(models.Model):
    LABEL_CHOICES = (
        ("home", "Home"),
        ("work", "Work"),
        ("other", "Other"),
    )

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="addresses",
    )
    label = models.CharField(max_length=20, choices=LABEL_CHOICES, default="home")
    recipient_name = models.CharField(max_length=255)
    phone_number = models.CharField(max_length=20)
    street_address = models.TextField()
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    postal_code = models.CharField(max_length=20)
    is_primary = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-is_primary", "-updated_at"]

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)

        if self.is_primary:
            Address.objects.filter(user=self.user).exclude(id=self.id).update(
                is_primary=False
            )

    def __str__(self):
        return f"{self.user.email} - {self.label}"


class NotificationSettings(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='notification_settings',
    )
    order_updates = models.BooleanField(default=True)
    promotions = models.BooleanField(default=True)
    security_alerts = models.BooleanField(default=False)
    daily_reminders = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.user.email} - NotificationSettings"