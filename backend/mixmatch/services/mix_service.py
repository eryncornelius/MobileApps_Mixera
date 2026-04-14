"""Mix session service — create and update sessions."""
from django.core.exceptions import ValidationError

from mixmatch.models import MixSession, SessionStatus
from mixmatch.services.validation_service import validate_item_selection


def create_session(*, user) -> MixSession:
    """Create a new MixSession in PENDING state."""
    return MixSession.objects.create(user=user, status=SessionStatus.PENDING)


def set_selected_items(*, session: MixSession, item_ids: list[int]) -> MixSession:
    """
    Validate and set the selected wardrobe items on the session.

    Allowed from: PENDING or ITEMS_SELECTED (lets user change their selection).

    Args:
        session:  The MixSession to update.
        item_ids: List of WardrobeItem pks to select.

    Returns:
        Updated MixSession.

    Raises:
        ValidationError if the session is already completed/failed, or
        if the item selection fails validation rules.
    """
    if session.status in (SessionStatus.COMPLETED, SessionStatus.FAILED):
        raise ValidationError(
            f"Cannot modify a session with status '{session.status}'."
        )

    items = validate_item_selection(item_ids=item_ids, user=session.user)

    session.selected_items.set(items)
    session.status = SessionStatus.ITEMS_SELECTED
    session.save(update_fields=["status", "updated_at"])

    return session
