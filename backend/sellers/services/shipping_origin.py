"""Asal ongkir: kode pos toko seller; fallback ke settings untuk produk platform."""

from __future__ import annotations

import re

from django.conf import settings

from sellers.models import SellerProfile
from sellers.services.seller_cart_service import cart_seller_state


def normalize_id_postal_code(raw: str) -> str:
    s = re.sub(r"\D", "", (raw or "").strip())
    return s[:5] if len(s) >= 5 else ""


def settings_fallback_origin() -> str:
    o = (getattr(settings, "BITESHIP_ORIGIN_POSTAL_CODE", "") or "").strip().replace(" ", "")
    if o.isdigit() and len(o) >= 5:
        return o[:5]
    return "12430"


def origin_postal_from_seller_user(user) -> str:
    """Kode pos asal dari profil seller (5 digit). Kosong jika belum diisi."""
    if not user:
        return ""
    p = SellerProfile.objects.filter(user=user).only("ship_from_postal_code").first()
    if not p:
        return ""
    return normalize_id_postal_code(p.ship_from_postal_code or "")


def origin_postal_for_cart(cart) -> str:
    """
    Keranjang seller: pakai SellerProfile.ship_from_postal_code penjual.
    Platform-only / kosong: BITESHIP_ORIGIN_POSTAL_CODE (atau default).
    """
    state, sid = cart_seller_state(cart)
    if state != "seller" or not sid:
        return settings_fallback_origin()
    row = cart.items.select_related("variant__product__seller").first()
    if not row or not row.variant.product.seller_id:
        return settings_fallback_origin()
    seller = row.variant.product.seller
    pc = origin_postal_from_seller_user(seller)
    return pc if pc else settings_fallback_origin()
