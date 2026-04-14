"""Klien ringan Biteship Rates API (POST /v1/rates/couriers)."""

from __future__ import annotations

import logging
from typing import Any

import requests
from django.conf import settings

logger = logging.getLogger("mixera.sellers")

BITESHIP_API_BASE = "https://api.biteship.com/v1"


def _eta_days_from_row(p: dict[str, Any]) -> int:
    r = (p.get("shipment_duration_range") or "").replace(" ", "")
    if r:
        parts = [x for x in r.split("-") if x.isdigit()]
        if parts:
            return max(1, min(14, int(parts[-1])))
    dur = (p.get("duration") or "").lower()
    if "hour" in dur:
        return 1
    return 3


def biteship_courier_quotes(
    *,
    origin_postal_code: str,
    destination_postal_code: str,
    weight_grams: int,
    couriers: str,
) -> list[dict]:
    key = (getattr(settings, "BITESHIP_API_KEY", "") or "").strip()
    if not key:
        raise ValueError("BITESHIP_API_KEY kosong")

    ow = max(1, int(weight_grams or 1))
    origin = int(str(origin_postal_code).strip()[:5])
    dest = int(str(destination_postal_code).strip()[:5])

    payload: dict[str, Any] = {
        "origin_postal_code": origin,
        "destination_postal_code": dest,
        "couriers": couriers,
        "items": [
            {
                "name": "Paket",
                "description": "Perkiraan ongkir",
                "value": 100000,
                "quantity": 1,
                "weight": ow,
            }
        ],
    }

    url = f"{BITESHIP_API_BASE}/rates/couriers"
    resp = requests.post(
        url,
        json=payload,
        headers={
            "authorization": key,
            "content-type": "application/json",
        },
        timeout=30,
    )

    try:
        data = resp.json()
    except ValueError as exc:
        logger.warning("Biteship non-JSON response status=%s", resp.status_code)
        raise ValueError("Respons Biteship tidak valid") from exc

    if resp.status_code >= 400:
        msg = data.get("message") or data.get("error") or resp.text[:200]
        logger.warning("Biteship HTTP %s: %s", resp.status_code, msg)
        raise ValueError(str(msg))

    if not data.get("success"):
        msg = data.get("message") or "Gagal mengambil tarif"
        logger.warning("Biteship success=false: %s", msg)
        raise ValueError(str(msg))

    out: list[dict] = []
    for p in data.get("pricing") or []:
        price = p.get("price")
        if price is None:
            continue
        try:
            price_int = int(price)
        except (TypeError, ValueError):
            continue
        out.append(
            {
                "courier": p.get("courier_name") or p.get("company") or "",
                "service": p.get("courier_service_name") or p.get("courier_service_code") or "",
                "price": price_int,
                "eta_days": _eta_days_from_row(p),
                "provider": "biteship",
                "duration": p.get("duration") or "",
                "courier_code": p.get("courier_code") or "",
                "service_code": p.get("courier_service_code") or "",
            }
        )
    return out
