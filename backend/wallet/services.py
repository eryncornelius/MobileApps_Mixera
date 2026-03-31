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
