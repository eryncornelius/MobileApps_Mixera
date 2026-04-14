from django.db import transaction as db_transaction

from .models import Wallet, WalletTransaction


def credit_wallet(user, amount: int, reference: str, description: str = "Wallet Top Up") -> None:
    """
    Atomically add `amount` to the user's wallet and record a top_up transaction.
    Safe to call from the Midtrans notification handler.
    """
    with db_transaction.atomic():
        wallet, _ = Wallet.objects.select_for_update().get_or_create(user=user)
        wallet.balance += amount
        wallet.save(update_fields=['balance', 'updated_at'])
        WalletTransaction.objects.create(
            wallet=wallet,
            type='top_up',
            amount=amount,
            reference=reference,
            description=description,
        )


def try_credit_wallet_topup(*, user, gross_amount: int, payment_order_id: str) -> bool:
    """
    Idempotent: credit wallet once per Midtrans order_id (Core API / Snap top-up).
    Returns True if a new top_up row was created.
    """
    if not payment_order_id:
        return False
    if WalletTransaction.objects.filter(
        wallet__user_id=user.pk,
        reference=payment_order_id,
        type="top_up",
    ).exists():
        return False
    credit_wallet(user=user, amount=gross_amount, reference=payment_order_id)
    return True
