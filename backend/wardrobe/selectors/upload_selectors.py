"""Wardrobe upload selectors — query helpers for UploadBatch / UploadedPhoto."""
from django.shortcuts import get_object_or_404

from wardrobe.models import UploadBatch


def get_batch_for_user(*, batch_id: int, user) -> UploadBatch:
    """Return batch owned by user or raise 404."""
    return get_object_or_404(UploadBatch, pk=batch_id, user=user)


def get_batches_for_user(*, user):
    """Return all batches for the user, newest first."""
    return UploadBatch.objects.filter(user=user).prefetch_related("photos")
