"""Wardrobe item service — confirm selected candidates into WardrobeItems."""
from django.core.exceptions import ValidationError

from wardrobe.enums import BatchStatus
from wardrobe.models import DetectedItemCandidate, UploadBatch, WardrobeItem


def confirm_batch(*, batch: UploadBatch) -> list[WardrobeItem]:
    """
    Convert all selected candidates in this batch into WardrobeItem rows.

    Validation:
        - Batch status must be REVIEW_READY.
        - At least one candidate must be selected.

    Args:
        batch: The UploadBatch to confirm.

    Returns:
        List of created WardrobeItem instances.

    Raises:
        ValidationError on rule violations.
    """
    if batch.status != BatchStatus.REVIEW_READY:
        raise ValidationError(
            f"Cannot confirm batch with status '{batch.status}'. "
            "Batch must be in 'review_ready' state."
        )

    batch_photo_ids = batch.photos.values_list("id", flat=True)
    selected = list(
        DetectedItemCandidate.objects.filter(
            photo__id__in=batch_photo_ids,
            is_selected=True,
        ).select_related("photo")
    )

    if not selected:
        raise ValidationError(
            "At least one candidate must be selected before confirming."
        )

    items = []
    for candidate in selected:
        # Prefer AI crop so one outfit photo becomes distinct wardrobe thumbnails.
        item_image = (
            candidate.cropped_image if candidate.cropped_image else candidate.photo.image
        )
        item = WardrobeItem.objects.create(
            user=batch.user,
            source_candidate=candidate,
            category=candidate.category,
            subcategory=candidate.subcategory,
            color=candidate.color,
            style_tags=candidate.style_tags,
            image=item_image,
        )
        items.append(item)

    batch.status = BatchStatus.CONFIRMED
    batch.save(update_fields=["status", "updated_at"])

    return items
