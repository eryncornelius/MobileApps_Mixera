from orders.models import Order


def orders_for_seller(user):
    """Order yang punya minimal satu line item milik seller (via variant.product.seller)."""
    return (
        Order.objects.filter(items__variant__product__seller=user)
        .distinct()
        .select_related("user")
        .prefetch_related("items__variant__product")
        .order_by("-created_at")
    )


def seller_has_order(user, order):
    return Order.objects.filter(pk=order.pk, items__variant__product__seller=user).exists()
