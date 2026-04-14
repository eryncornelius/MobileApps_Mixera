import uuid

from django.utils.text import slugify

from shop.models import Product


def unique_product_slug(base_name: str) -> str:
    base = slugify(base_name)[:80] or "product"
    candidate = base
    if not Product.objects.filter(slug=candidate).exists():
        return candidate
    for _ in range(20):
        suffix = uuid.uuid4().hex[:8]
        candidate = f"{base}-{suffix}"
        if not Product.objects.filter(slug=candidate).exists():
            return candidate
    return f"{base}-{uuid.uuid4().hex}"


def unique_product_slug_for_update(base_name: str, exclude_product_id: int) -> str:
    """Slug unik saat rename produk; mengabaikan slug milik produk ini sendiri."""
    base = slugify(base_name)[:80] or "product"
    qs = Product.objects.exclude(pk=exclude_product_id)
    candidate = base
    if not qs.filter(slug=candidate).exists():
        return candidate
    for _ in range(20):
        suffix = uuid.uuid4().hex[:8]
        candidate = f"{base}-{suffix}"
        if not qs.filter(slug=candidate).exists():
            return candidate
    return f"{base}-{uuid.uuid4().hex}"
