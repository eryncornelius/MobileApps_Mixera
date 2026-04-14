"""Pencatatan pendapatan seller saat order shop berstatus dibayar (idempoten per order+seller)."""

from __future__ import annotations

from django.conf import settings
from django.db import transaction as db_transaction

from orders.models import Order


def record_seller_earnings_for_paid_order(order: Order) -> None:
    """
    Untuk tiap seller yang punya line item di order, buat satu SellerOrderEarning.
    Produk platform (seller null) diabaikan. Aman dipanggil ulang.
    """
    if order.payment_status != "paid":
        return

    from ..models import SellerNotification, SellerOrderEarning

    fee_bps = int(getattr(settings, "SELLER_PLATFORM_FEE_BPS", 1000))

    items = order.items.select_related("variant__product").all()
    buckets: dict[int, int] = {}
    for it in items:
        if not it.variant_id:
            continue
        sid = it.variant.product.seller_id
        if sid is None:
            continue
        buckets[sid] = buckets.get(sid, 0) + int(it.line_total)

    for seller_id, gross in buckets.items():
        fee = gross * fee_bps // 10000
        net = gross - fee
        with db_transaction.atomic():
            _, created = SellerOrderEarning.objects.get_or_create(
                order=order,
                seller_id=seller_id,
                defaults={
                    "item_subtotal_gross": gross,
                    "platform_fee": fee,
                    "net_to_seller": net,
                },
            )
            if created:
                SellerNotification.objects.create(
                    seller_id=seller_id,
                    title="Pesanan dibayar",
                    body=f"Order #{order.pk}: bruto Rp {gross}, estimasi bersih Rp {net} (setelah komisi).",
                )
