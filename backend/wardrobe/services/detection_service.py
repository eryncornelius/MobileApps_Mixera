"""Wardrobe detection service — runs AI analysis on uploaded photos."""
import logging

from wardrobe.ai.client import WardrobeAIClient
from wardrobe.enums import BatchStatus
from wardrobe.models import DetectedItemCandidate, UploadBatch, UploadedPhoto
from wardrobe.services.candidate_ai_cutout import try_ai_garment_cutout
from wardrobe.services.candidate_image_crop import candidate_crop_content_file

logger = logging.getLogger(__name__)

_ai_client = WardrobeAIClient()


def run_detection_for_batch(*, batch: UploadBatch) -> None:
    """
    Run detection on all photos in a batch and create DetectedItemCandidate
    rows. Updates batch status to REVIEW_READY on success, FAILED on error.

    Called synchronously after photo upload. Replace with async task later.
    """
    batch.status = BatchStatus.PROCESSING
    batch.save(update_fields=["status", "updated_at"])

    try:
        photos = list(batch.photos.all())
        for photo in photos:
            _detect_photo(photo)

        batch.status = BatchStatus.REVIEW_READY
        batch.save(update_fields=["status", "updated_at"])

    except Exception as exc:
        logger.exception("Detection failed for batch %s: %s", batch.pk, exc)
        batch.status = BatchStatus.FAILED
        batch.save(update_fields=["status", "updated_at"])
        raise


def _detect_photo(photo: UploadedPhoto) -> None:
    """Run AI detection on a single photo, persist candidate rows."""
    image_path = photo.image.path
    candidates = _ai_client.detect_items(image_path)

    for result in candidates:
        bbox_dict = result.bounding_box_dict()
        crop_file = try_ai_garment_cutout(
            image_path,
            category=result.category,
            subcategory=result.subcategory,
            color=result.color,
            bounding_box=bbox_dict,
        ) or candidate_crop_content_file(image_path, bbox_dict)
        DetectedItemCandidate.objects.create(
            photo=photo,
            category=result.category,
            subcategory=result.subcategory,
            color=result.color,
            style_tags=result.style_tags,
            confidence=result.confidence,
            bounding_box=bbox_dict,
            cropped_image=crop_file,
            ai_raw_response=result.raw_response,
            is_selected=False,
        )
