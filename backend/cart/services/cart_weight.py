"""Estimasi berat keranjang untuk Rates API (per unit konfigurasi)."""

from django.conf import settings


def estimated_cart_weight_grams(cart) -> int:
    per = int(getattr(settings, "CART_ESTIMATE_WEIGHT_GRAMS_PER_UNIT", 200))
    total = 0
    for it in cart.items.all():
        total += per * int(it.quantity or 1)
    return max(per, total)
