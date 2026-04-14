"""Mixmatch selectors — owner-scoped query helpers."""
from django.shortcuts import get_object_or_404

from mixmatch.models import MixResult, MixSession


def get_session_for_user(*, session_id: int, user) -> MixSession:
    """Return session owned by user or raise 404."""
    return get_object_or_404(MixSession, pk=session_id, user=user)


def get_result_for_user(*, result_id: int, user) -> MixResult:
    """Return result whose session is owned by user or raise 404."""
    return get_object_or_404(MixResult, pk=result_id, session__user=user)


def get_saved_results_for_user(*, user):
    """Return all saved mix results for the user, newest first."""
    return (
        MixResult.objects.filter(session__user=user, is_saved=True)
        .select_related("session")
        .prefetch_related("session__selected_items")
        .order_by("-created_at")
    )
