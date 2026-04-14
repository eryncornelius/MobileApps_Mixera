"""
Menandai order shop Midtrans sebagai paid + mengosongkan cart + ledger seller.
Dipakai di webhook, polling status, dan respons charge langsung.
"""

from __future__ import annotations

from django.db import transaction as db_transaction

from cart.models import Cart
from orders.models import Order

from payments.models import PaymentTransaction


def try_settle_shop_order_payment(*, tx: PaymentTransaction) -> bool:
    """
    Jika transaksi shop_order sudah settlement/capture dan lolos fraud,
    tandai Order terkait paid (sekali) dan hapus item cart pembeli.

    Returns True jika baris order benar-benar di-update ke paid.
    """
    if tx.purpose != "shop_order" or not tx.linked_order_id:
        return False
    if tx.transaction_status not in ("capture", "settlement"):
        return False
    fraud = tx.fraud_status
    if fraud not in ("accept", None, ""):
        return False

    with db_transaction.atomic():
        updated = Order.objects.filter(
            pk=tx.linked_order_id,
            user_id=tx.user_id,
            payment_status="unpaid",
        ).update(payment_status="paid", status="processing")
        if not updated:
            return False
        cart = Cart.objects.filter(user_id=tx.user_id).first()
        if cart:
            cart.items.all().delete()

    order = Order.objects.get(pk=tx.linked_order_id)
    from sellers.services.ledger_service import record_seller_earnings_for_paid_order

    record_seller_earnings_for_paid_order(order)
    return True
