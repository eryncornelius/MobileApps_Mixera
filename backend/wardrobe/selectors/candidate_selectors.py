"""Wardrobe candidate selectors — query helpers for DetectedItemCandidate."""
from wardrobe.models import DetectedItemCandidate, UploadBatch


def get_candidates_for_batch(*, batch: UploadBatch):
    """Return all candidates belonging to any photo of the given batch."""
    photo_ids = batch.photos.values_list("id", flat=True)
    return DetectedItemCandidate.objects.filter(
        photo__id__in=photo_ids
    ).select_related("photo").order_by("photo_id", "id")
