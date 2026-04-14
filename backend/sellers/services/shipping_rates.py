"""Gabungan tarif: Biteship (jika API key + kode pos) atau stub lokal."""

from __future__ import annotations

import logging
import re

from django.conf import settings

from .biteship_client import biteship_courier_quotes
from .shipping_stub import quote_shipping as stub_quotes

logger = logging.getLogger("mixera.sellers")


def _extract_postal(text: str) -> str:
    if not text:
        return ""
    m = re.search(r"\b(\d{5})\b", text)
    return m.group(1) if m else ""


def resolve_shipping_quotes(
    *,
    weight_grams: int,
    destination_city: str = "",
    destination_postal_code: str = "",
    origin_postal_code: str | None = None,
) -> tuple[list[dict], str]:
    """
    Returns (quotes, note_for_client).
    """
    raw_dest = (destination_postal_code or "").strip().replace(" ", "")
    dest = ""
    if raw_dest.isdigit() and len(raw_dest) >= 5:
        dest = raw_dest[:5]
    if len(dest) < 5:
        dest = _extract_postal(destination_city or "")

    if origin_postal_code:
        origin_raw = str(origin_postal_code).strip().replace(" ", "")
    else:
        origin_raw = (getattr(settings, "BITESHIP_ORIGIN_POSTAL_CODE", "") or "").strip().replace(" ", "")
    if origin_raw.isdigit() and len(origin_raw) >= 5:
        origin = origin_raw[:5]
    else:
        origin = "12430"

    couriers = (getattr(settings, "BITESHIP_COURIERS", "") or "jne,sicepat,tiki").strip()
    api_key = (getattr(settings, "BITESHIP_API_KEY", "") or "").strip()

    if api_key and len(dest) >= 5:
        try:
            quotes = biteship_courier_quotes(
                origin_postal_code=origin,
                destination_postal_code=dest,
                weight_grams=weight_grams,
                couriers=couriers,
            )
            if quotes:
                return quotes, f"Biteship — asal {origin} → {dest} ({couriers})."
        except Exception as exc:
            logger.warning("Biteship rates gagal, fallback stub: %s", exc)

    quotes = stub_quotes(weight_grams=weight_grams, destination_city=destination_city)
    note = "Perkiraan lokal (stub)."
    if api_key and len(dest) < 5:
        note += " Tambahkan kode pos tujuan (5 digit) untuk tarif Biteship."
    elif api_key:
        note += " Biteship tidak tersedia — menampilkan perkiraan lokal."
    return quotes, note
