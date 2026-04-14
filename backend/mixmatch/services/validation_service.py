"""Mix selection validation — ownership and category rules."""
from django.core.exceptions import ValidationError

from wardrobe.models import WardrobeItem

MAX_ITEMS = 5
MIN_ITEMS = 1
REQUIRED_CATEGORIES = {"top", "bottom"}


def validate_item_selection(*, item_ids: list[int], user) -> list[WardrobeItem]:
    """
    Validate that the given wardrobe item ids are usable for a mix session.

    Rules enforced:
      - At least 1 item, at most 5 items
      - All items must belong to the requesting user
      - At least 1 item with category 'top'
      - At least 1 item with category 'bottom'

    Returns:
        Resolved list of WardrobeItem instances (in the same order).

    Raises:
        ValidationError with a descriptive message on any failure.
    """
    if not item_ids:
        raise ValidationError("At least one wardrobe item must be selected.")

    if len(item_ids) > MAX_ITEMS:
        raise ValidationError(
            f"You can select at most {MAX_ITEMS} items per mix session "
            f"(received {len(item_ids)})."
        )

    items = list(
        WardrobeItem.objects.filter(id__in=item_ids, user=user)
    )

    if len(items) != len(set(item_ids)):
        found_ids = {item.id for item in items}
        missing = set(item_ids) - found_ids
        raise ValidationError(
            f"Wardrobe items not found or not owned by you: {sorted(missing)}."
        )

    categories = {item.category for item in items}

    missing_required = REQUIRED_CATEGORIES - categories
    if missing_required:
        labels = " and ".join(
            f"at least one '{c}'" for c in sorted(missing_required)
        )
        raise ValidationError(
            f"Your selection must include {labels}."
        )

    return items
