"""Validasi ongkir checkout terhadap tarif Biteship/stub + default flat."""

from __future__ import annotations

import re

from django.conf import settings

from cart.services.cart_weight import estimated_cart_weight_grams
from sellers.services.shipping_origin import origin_postal_for_cart
from sellers.services.shipping_rates import resolve_shipping_quotes


def _destination_postal_digits(address) -> str:
    raw = re.sub(r"\D", "", getattr(address, "postal_code", None) or "")
    return raw[:5] if len(raw) >= 5 else ""


def allowed_delivery_fees_for_checkout(*, cart, address) -> set[int]:
    """Harga ongkir yang boleh dipakai: default platform + hasil rates untuk keranjang & kode pos."""
    default = int(getattr(settings, "DEFAULT_DELIVERY_FEE", 20000))
    fees: set[int] = {default}
    dest = _destination_postal_digits(address)
    weight = estimated_cart_weight_grams(cart)
    origin_pc = origin_postal_for_cart(cart)
    quotes, _ = resolve_shipping_quotes(
        weight_grams=weight,
        destination_city="",
        destination_postal_code=dest,
        origin_postal_code=origin_pc,
    )
    for q in quotes:
        p = q.get("price")
        if p is None:
            continue
        try:
            fees.add(int(p))
        except (TypeError, ValueError):
            continue
    return fees


def validated_delivery_fee(*, cart, address, requested) -> int:
    """
    - requested None / '' → DEFAULT_DELIVERY_FEE
    - requested int → harus anggota allowed_delivery_fees_for_checkout
    """
    default = int(getattr(settings, "DEFAULT_DELIVERY_FEE", 20000))
    allowed = allowed_delivery_fees_for_checkout(cart=cart, address=address)

    if requested is None or requested == "":
        return default

    try:
        rf = int(requested)
    except (TypeError, ValueError):
        raise ValueError("delivery_fee harus berupa bilangan bulat.")

    if rf not in allowed:
        raise ValueError(
            "delivery_fee tidak valid untuk alamat dan isi keranjang saat ini. "
            "Ambil ulang perkiraan ongkir lalu pilih tarif yang tercantum."
        )
    return rf
