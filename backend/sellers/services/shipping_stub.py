"""Placeholder ongkir — ganti dengan API kurir sungguhan di fase integrasi."""


def quote_shipping(*, weight_grams: int, destination_city: str = "") -> list[dict]:
    _ = destination_city
    w = max(0, int(weight_grams or 0))
    base = 18000 + min(w // 500, 8) * 1500
    return [
        {
            "courier": "JNE",
            "service": "REG",
            "price": base + 2000,
            "eta_days": 3,
            "provider": "stub",
        },
        {
            "courier": "SiCepat",
            "service": "REG",
            "price": base,
            "eta_days": 4,
            "provider": "stub",
        },
    ]
