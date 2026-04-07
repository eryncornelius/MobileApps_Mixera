"""Wardrobe item selectors — query helpers for WardrobeItem."""
from wardrobe.models import WardrobeItem


def get_items_for_user(*, user, category: str = None):
    """Return wardrobe items for the user, optionally filtered by category."""
    qs = WardrobeItem.objects.filter(user=user)
    if category:
        qs = qs.filter(category=category)
    return qs


def get_category_summary_for_user(*, user) -> list[dict]:
    """
    Return a count of wardrobe items grouped by category.

    Example output:
        [{"category": "top", "count": 5}, {"category": "shoes", "count": 3}]
    """
    from django.db.models import Count
    from wardrobe.enums import ClothingCategory

    counts = (
        WardrobeItem.objects.filter(user=user)
        .values("category")
        .annotate(count=Count("id"))
        .order_by("category")
    )
    count_map = {row["category"]: row["count"] for row in counts}

    return [
        {"category": choice.value, "count": count_map.get(choice.value, 0)}
        for choice in ClothingCategory
    ]
