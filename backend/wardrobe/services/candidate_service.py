"""Wardrobe candidate service — update candidate selections during review."""
from django.core.exceptions import ValidationError

from wardrobe.models import DetectedItemCandidate, UploadBatch


def update_candidates(*, batch: UploadBatch, updates: list[dict]) -> list[DetectedItemCandidate]:
    """
    Apply user review edits to candidates belonging to this batch.

    Each entry in `updates` must contain `id` plus any subset of:
        is_selected, category, subcategory, color, style_tags

    Args:
        batch:   The owning UploadBatch (used to scope the query).
        updates: List of dicts from the PATCH request payload.

    Returns:
        List of updated DetectedItemCandidate instances.

    Raises:
        ValidationError if a candidate id doesn't belong to this batch.
    """
    ALLOWED_FIELDS = {"is_selected", "category", "subcategory", "color", "style_tags"}
    batch_photo_ids = batch.photos.values_list("id", flat=True)

    updated = []
    for entry in updates:
        candidate_id = entry.get("id")
        candidate = DetectedItemCandidate.objects.filter(
            id=candidate_id,
            photo__id__in=batch_photo_ids,
        ).first()

        if candidate is None:
            raise ValidationError(
                f"Candidate {candidate_id} does not belong to batch {batch.pk}."
            )

        changed = False
        for field in ALLOWED_FIELDS:
            if field in entry:
                setattr(candidate, field, entry[field])
                changed = True

        if changed:
            candidate.save()

        updated.append(candidate)

    return updated
