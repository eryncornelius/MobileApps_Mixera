from django.conf import settings
from django.db import models

from wardrobe.enums import BatchStatus, ClothingCategory


class UploadBatch(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="upload_batches",
    )
    status = models.CharField(
        max_length=20,
        choices=BatchStatus.choices,
        default=BatchStatus.PENDING,
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"UploadBatch #{self.pk} ({self.user.email}) - {self.status}"


class UploadedPhoto(models.Model):
    batch = models.ForeignKey(
        UploadBatch,
        on_delete=models.CASCADE,
        related_name="photos",
    )
    image = models.ImageField(upload_to="wardrobe/uploads/%Y/%m/")
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Photo #{self.pk} → Batch #{self.batch_id}"


class DetectedItemCandidate(models.Model):
    photo = models.ForeignKey(
        UploadedPhoto,
        on_delete=models.CASCADE,
        related_name="candidates",
    )
    is_selected = models.BooleanField(default=False)

    # Clothing classification
    category = models.CharField(
        max_length=20,
        choices=ClothingCategory.choices,
        default=ClothingCategory.OTHER,
    )
    subcategory = models.CharField(max_length=100, blank=True, default="")
    color = models.CharField(max_length=100, blank=True, default="")
    style_tags = models.JSONField(default=list, blank=True)

    # AI metadata
    confidence = models.FloatField(null=True, blank=True)
    bounding_box = models.JSONField(null=True, blank=True)  # {x, y, width, height} in px
    cropped_image = models.ImageField(
        upload_to="wardrobe/crops/%Y/%m/", null=True, blank=True
    )
    ai_raw_response = models.JSONField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Candidate #{self.pk} ({self.category}) → Photo #{self.photo_id}"


class WardrobeItem(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="wardrobe_items",
    )
    source_candidate = models.OneToOneField(
        DetectedItemCandidate,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="wardrobe_item",
    )

    # Clothing classification (copied from candidate, editable)
    category = models.CharField(
        max_length=20,
        choices=ClothingCategory.choices,
        default=ClothingCategory.OTHER,
    )
    subcategory = models.CharField(max_length=100, blank=True, default="")
    color = models.CharField(max_length=100, blank=True, default="")
    style_tags = models.JSONField(default=list, blank=True)

    image = models.ImageField(upload_to="wardrobe/items/%Y/%m/")
    name = models.CharField(max_length=255, blank=True, default="")
    notes = models.TextField(blank=True, default="")

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"WardrobeItem #{self.pk} ({self.category}) - {self.user.email}"
