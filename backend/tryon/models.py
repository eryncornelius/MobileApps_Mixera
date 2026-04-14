from django.conf import settings
from django.core.exceptions import ValidationError
from django.db import models
from django.db.models import Q


class RequestStatus(models.TextChoices):
    PENDING = "pending", "Pending"
    PROCESSING = "processing", "Processing"
    COMPLETED = "completed", "Completed"
    FAILED = "failed", "Failed"


class TryOnSourceType(models.TextChoices):
    MIX_RESULT = "mix_result", "Mix Result"
    SHOP_PRODUCT = "shop_product", "Shop Product"


class PersonProfileImage(models.Model):
    """
    A photo of the user's body used for virtual try-on.
    Kept separate from wardrobe clothing items.
    """

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="person_images",
    )
    image = models.ImageField(upload_to="tryon/persons/%Y/%m/")
    label = models.CharField(max_length=100, blank=True, default="")
    is_active = models.BooleanField(default=False)
    is_archived = models.BooleanField(
        default=False,
        db_index=True,
        help_text="Soft-hide from library; kept so TryOnRequest.person_image (PROTECT) stays valid.",
    )
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-uploaded_at"]

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        if self.is_active and not self.is_archived:
            PersonProfileImage.objects.filter(user=self.user).exclude(pk=self.pk).update(is_active=False)

    def __str__(self):
        active_flag = " [active]" if self.is_active else ""
        return f"PersonImage #{self.pk} ({self.user.email}){active_flag}"


class TryOnRequest(models.Model):
    """
    A request to apply an outfit onto a person image.

    source_type determines which reference field is active:
      - mix_result   -> mix_result FK must be set; shop_product must be null
      - shop_product -> shop_product FK must be set; mix_result must be null
    """

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="tryon_requests",
    )
    person_image = models.ForeignKey(
        PersonProfileImage,
        on_delete=models.PROTECT,
        related_name="tryon_requests",
    )
    source_type = models.CharField(
        max_length=20,
        choices=TryOnSourceType.choices,
        default=TryOnSourceType.MIX_RESULT,
    )

    # Populated when source_type = mix_result
    mix_result = models.ForeignKey(
        "mixmatch.MixResult",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="tryon_requests",
    )

    # Populated when source_type = shop_product
    shop_product = models.ForeignKey(
        "shop.Product",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="tryon_requests",
    )

    status = models.CharField(
        max_length=20,
        choices=RequestStatus.choices,
        default=RequestStatus.PENDING,
    )
    error_message = models.TextField(blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        constraints = [
            models.CheckConstraint(
                name="tryonrequest_valid_mix_result_source",
                condition=(
                    Q(source_type=TryOnSourceType.MIX_RESULT, mix_result__isnull=False, shop_product__isnull=True)
                    | Q(source_type=TryOnSourceType.SHOP_PRODUCT, shop_product__isnull=False, mix_result__isnull=True)
                ),
            ),
        ]

    def clean(self):
        if self.source_type == TryOnSourceType.MIX_RESULT:
            if not self.mix_result:
                raise ValidationError(
                    {"mix_result": "mix_result is required when source_type is 'mix_result'."}
                )
            if self.shop_product:
                raise ValidationError(
                    {"shop_product": "shop_product must be empty when source_type is 'mix_result'."}
                )

        elif self.source_type == TryOnSourceType.SHOP_PRODUCT:
            if not self.shop_product:
                raise ValidationError(
                    {"shop_product": "shop_product is required when source_type is 'shop_product'."}
                )
            if self.mix_result:
                raise ValidationError(
                    {"mix_result": "mix_result must be empty when source_type is 'shop_product'."}
                )

        if self.person_image and self.user_id and self.person_image.user_id != self.user_id:
            raise ValidationError(
                {"person_image": "person_image must belong to the same authenticated user."}
            )

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"TryOnRequest #{self.pk} ({self.user.email}) [{self.source_type}] - {self.status}"


class TryOnResult(models.Model):
    """
    The output of a try-on request.
    Stores the result image (real output) or a placeholder for now.
    """

    request = models.OneToOneField(
        TryOnRequest,
        on_delete=models.CASCADE,
        related_name="result",
    )
    result_image = models.ImageField(
        upload_to="tryon/results/%Y/%m/",
        null=True,
        blank=True,
    )
    notes = models.TextField(blank=True, default="")
    is_saved = models.BooleanField(
        default=False,
        db_index=True,
        help_text="User favourite — shown in saved try-on section.",
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"TryOnResult #{self.pk} -> Request #{self.request_id}"