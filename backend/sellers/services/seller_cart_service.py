"""Aturan keranjang: satu seller per checkout; produk platform (tanpa seller) tidak dicampur dengan produk seller."""


def cart_seller_state(cart):
    """
    ('empty', None) | ('platform', None) | ('seller', user_id) | ('mixed', None)
    """
    rows = (
        cart.items.select_related("variant__product")
        .values_list("variant__product__seller_id", flat=True)
    )
    seller_ids = set(rows)
    if not seller_ids:
        return "empty", None
    if seller_ids == {None}:
        return "platform", None
    non_null = {x for x in seller_ids if x is not None}
    if None in seller_ids and non_null:
        return "mixed", None
    if len(non_null) > 1:
        return "mixed", None
    return "seller", non_null.pop()


def can_add_variant(cart, product):
    new_sid = getattr(product, "seller_id", None)
    state, sid = cart_seller_state(cart)

    if state == "empty":
        return True, None
    if state == "mixed":
        return False, "Cart has invalid mix; clear cart and try again."
    if state == "platform":
        if new_sid is not None:
            return False, "Cart contains platform products. Clear cart before adding seller products."
        return True, None
    # state == 'seller'
    if new_sid is None:
        return False, "Cart contains seller products. Clear cart before adding platform products."
    if new_sid != sid:
        return False, "Cart contains products from another seller. Clear cart first."
    return True, None


def assert_checkout_allowed(cart):
    """Panggil saat checkout; mixed tidak boleh lolos."""
    state, _ = cart_seller_state(cart)
    if state == "mixed":
        raise ValueError("Cart contains products from multiple sources. Clear cart and add items again.")
    return state
