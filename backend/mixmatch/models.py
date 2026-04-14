from django.conf import settings
from django.db import models

from wardrobe.models import WardrobeItem


class SessionStatus(models.TextChoices):
    PENDING = "pending", "Pending"
    ITEMS_SELECTED = "items_selected", "Items Selected"
    COMPLETED = "completed", "Completed"
    FAILED = "failed", "Failed"


class MixSession(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="mix_sessions",
    )
    status = models.CharField(
        max_length=20,
        choices=SessionStatus.choices,
        default=SessionStatus.PENDING,
    )
    selected_items = models.ManyToManyField(
        WardrobeItem,
        blank=True,
        related_name="mix_sessions",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"MixSession #{self.pk} ({self.user.email}) - {self.status}"


class MixResult(models.Model):
    session = models.OneToOneField(
        MixSession,
        on_delete=models.CASCADE,
        related_name="result",
    )
    style_label = models.CharField(max_length=100, default="Balanced")
    explanation = models.TextField(blank=True, default="")
    tips = models.TextField(blank=True, default="")  # AI-generated styling suggestion
    score = models.IntegerField(default=50)  # 0–100 compatibility score
    is_saved = models.BooleanField(default=False)
    # Stacked 2D collage of selected wardrobe images (not AI try-on).
    preview_image = models.ImageField(
        upload_to="mixmatch/previews/%Y/%m/",
        null=True,
        blank=True,
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"MixResult #{self.pk} (session #{self.session_id}) - {self.style_label}"
