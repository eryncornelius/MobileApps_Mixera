"""Wardrobe upload service — create batches and add photos."""
from django.core.exceptions import ValidationError

from wardrobe.enums import BatchStatus
from wardrobe.models import UploadBatch, UploadedPhoto

MAX_PHOTOS_PER_BATCH = 3


def create_batch(*, user) -> UploadBatch:
    """Create a new UploadBatch for the given user."""
    return UploadBatch.objects.create(user=user, status=BatchStatus.PENDING)


def add_photos_to_batch(*, batch: UploadBatch, images: list) -> list[UploadedPhoto]:
    """
    Validate and persist uploaded image files to the batch.

    Args:
        batch:  The UploadBatch to attach photos to.
        images: List of InMemoryUploadedFile / TemporaryUploadedFile objects.

    Returns:
        List of created UploadedPhoto instances.

    Raises:
        ValidationError if photo limit exceeded.
    """
    existing = batch.photos.count()
    incoming = len(images)

    if existing + incoming > MAX_PHOTOS_PER_BATCH:
        raise ValidationError(
            f"A batch may contain at most {MAX_PHOTOS_PER_BATCH} photos "
            f"(already has {existing}, tried to add {incoming})."
        )

    photos = []
    for image_file in images:
        photo = UploadedPhoto.objects.create(batch=batch, image=image_file)
        photos.append(photo)

    return photos
