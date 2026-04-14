from django.db.models import Sum

from ..models import SellerOrderEarning, SellerPayoutRequest


def seller_available_balance(user) -> int:
    earned = (
        SellerOrderEarning.objects.filter(seller=user).aggregate(s=Sum("net_to_seller"))["s"] or 0
    )
    paid_out = (
        SellerPayoutRequest.objects.filter(seller=user, status=SellerPayoutRequest.Status.PAID).aggregate(
            s=Sum("amount")
        )["s"]
        or 0
    )
    pending = (
        SellerPayoutRequest.objects.filter(
            seller=user, status=SellerPayoutRequest.Status.PENDING
        ).aggregate(s=Sum("amount"))["s"]
        or 0
    )
    return int(earned) - int(paid_out) - int(pending)
