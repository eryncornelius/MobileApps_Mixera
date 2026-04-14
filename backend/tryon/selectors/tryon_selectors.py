"""Tryon selectors — owner-scoped query helpers."""
from django.shortcuts import get_object_or_404

from tryon.models import PersonProfileImage, TryOnRequest, TryOnResult


def get_person_images_for_user(*, user):
    """Return non-archived person images for the user, newest first."""
    return PersonProfileImage.objects.filter(user=user, is_archived=False)


def get_person_image_for_user(*, image_id: int, user) -> PersonProfileImage:
    """Return person image owned by user or raise 404."""
    return get_object_or_404(PersonProfileImage, pk=image_id, user=user)


def get_active_person_image(*, user) -> PersonProfileImage | None:
    """Return the user's currently active person image, or None."""
    return PersonProfileImage.objects.filter(user=user, is_active=True, is_archived=False).first()


def get_request_for_user(*, request_id: int, user) -> TryOnRequest:
    """Return try-on request owned by user or raise 404."""
    return get_object_or_404(TryOnRequest, pk=request_id, user=user)


def get_result_for_user(*, result_id: int, user) -> TryOnResult:
    """Return try-on result whose request is owned by user or raise 404."""
    return get_object_or_404(TryOnResult, pk=result_id, request__user=user)


def get_saved_tryon_results_for_user(*, user):
    """Favourited try-on results for the user, newest first."""
    return (
        TryOnResult.objects.filter(request__user=user, is_saved=True)
        .select_related("request")
        .order_by("-created_at")
    )
