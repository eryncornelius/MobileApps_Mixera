"""
Seed data marketplace untuk uji E2E.

Default seller: xiaoshisui174@gmail.com (bisa di-override --email).

Password:
  --password "..." ATAU env SEED_SELLER_PASSWORD
  jika tidak ada: MixeraSeed1! (ganti setelah tes / jangan dipakai production)

Contoh:
  python manage.py seed_marketplace_demo
  python manage.py seed_marketplace_demo --email other@mail.com --password 'MyStr0ng!Pass'
"""

from __future__ import annotations

import os

from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand
from django.db import transaction

from sellers.models import SellerProfile
from sellers.services.product_slug import unique_product_slug
from shop.models import Category, Product, ProductImage, ProductVariant
from users.models import Address
from wallet.models import Wallet

User = get_user_model()

DEFAULT_SELLER_EMAIL = "xiaoshisui174@gmail.com"
DEFAULT_DEV_PASSWORD = "MixeraSeed1!"
DEFAULT_BUYER_EMAIL = "buyer.demo@mixera.local"

DEMO_IMAGE = "https://picsum.photos/seed/mixerademo/800/1000"


def _username_for_email(email: str) -> str:
    local = email.split("@")[0].replace(".", "_")[:25]
    base = local or "user"
    candidate = base
    n = 0
    while User.objects.filter(username=candidate).exists():
        n += 1
        candidate = f"{base}_{n}"[:30]
    return candidate


class Command(BaseCommand):
    help = "Buat/isi seller demo, profil toko, kategori, dan produk contoh untuk tes marketplace."

    def add_arguments(self, parser):
        parser.add_argument(
            "--email",
            default=DEFAULT_SELLER_EMAIL,
            help=f"Email seller (default: {DEFAULT_SELLER_EMAIL})",
        )
        parser.add_argument(
            "--password",
            default=None,
            help="Password login seller. Default: env SEED_SELLER_PASSWORD atau MixeraSeed1!",
        )
        parser.add_argument(
            "--force-products",
            action="store_true",
            help="Tambah produk demo walaupun seller sudah punya produk.",
        )
        parser.add_argument(
            "--buyer-email",
            default=DEFAULT_BUYER_EMAIL,
            help=f"Email buyer demo (default: {DEFAULT_BUYER_EMAIL})",
        )
        parser.add_argument(
            "--buyer-password",
            default=None,
            help="Password buyer demo. Default: env SEED_BUYER_PASSWORD atau MixeraSeed1!",
        )
        parser.add_argument(
            "--wallet-balance",
            type=int,
            default=500000,
            help="Saldo wallet buyer demo (default: 500000).",
        )

    @transaction.atomic
    def handle(self, *args, **options):
        email = (options["email"] or DEFAULT_SELLER_EMAIL).strip().lower()
        password = (
            options["password"]
            or os.environ.get("SEED_SELLER_PASSWORD")
            or DEFAULT_DEV_PASSWORD
        )

        user = User.objects.filter(email__iexact=email).first()
        if user:
            self.stdout.write(self.style.WARNING(f"User sudah ada: {email} (id={user.pk})"))
            user.is_seller = True
            user.is_email_verified = True
            user.set_password(password)
            user.save(update_fields=["is_seller", "is_email_verified", "password"])
        else:
            user = User.objects.create_user(
                email=email,
                username=_username_for_email(email),
                password=password,
                auth_provider="email",
                is_email_verified=True,
                is_seller=True,
            )
            self.stdout.write(self.style.SUCCESS(f"User seller dibuat: {email} (id={user.pk})"))

        profile, created = SellerProfile.objects.get_or_create(
            user=user,
            defaults={
                "store_name": "Mixera Demo Store",
                "ship_from_postal_code": "12430",
            },
        )
        if not created:
            if not profile.store_name:
                profile.store_name = "Mixera Demo Store"
            if not profile.ship_from_postal_code:
                profile.ship_from_postal_code = "12430"
            profile.save(update_fields=["store_name", "ship_from_postal_code", "updated_at"])
        self.stdout.write(
            self.style.SUCCESS(
                f"SellerProfile: store={profile.store_name!r} ship_from={profile.ship_from_postal_code!r}"
            )
        )

        cat, _ = Category.objects.get_or_create(
            slug="demo-fashion",
            defaults={"name": "Fashion Demo"},
        )

        existing_products = Product.objects.filter(seller=user).count()
        if existing_products > 0 and not options["force_products"]:
            self.stdout.write(
                self.style.WARNING(
                    f"Lewati produk demo (seller sudah punya {existing_products} produk). "
                    f"Pakai --force-products untuk menambah lagi."
                )
            )
        else:
            self._seed_products(user, cat)

        buyer_email = (options["buyer_email"] or DEFAULT_BUYER_EMAIL).strip().lower()
        buyer_password = (
            options["buyer_password"]
            or os.environ.get("SEED_BUYER_PASSWORD")
            or DEFAULT_DEV_PASSWORD
        )
        wallet_balance = max(int(options.get("wallet_balance") or 0), 0)
        buyer = self._seed_buyer_demo(
            email=buyer_email,
            password=buyer_password,
            wallet_balance=wallet_balance,
        )

        self.stdout.write("")
        self.stdout.write(self.style.SUCCESS("Selesai. Login seller dengan email di atas."))
        self.stdout.write(
            "Password: dari --password, env SEED_SELLER_PASSWORD, atau default dev MixeraSeed1!"
        )
        self.stdout.write(
            self.style.SUCCESS(f"Buyer demo: {buyer.email} (password sama pola di atas / --buyer-password)")
        )
        self.stdout.write(
            self.style.SUCCESS(
                f"Buyer wallet diset: Rp {wallet_balance} dan alamat primary sudah dibuat."
            )
        )

    def _seed_products(self, user: User, category: Category) -> None:
        specs = [
            {
                "name": "Kaos Oversize Demo",
                "price": 149000,
                "discount_price": 129000,
                "color": "Hitam",
                "sizes": [("S", 10), ("M", 15), ("L", 12)],
            },
            {
                "name": "Kemeja Linen Demo",
                "price": 259000,
                "discount_price": None,
                "color": "Krem",
                "sizes": [("M", 8), ("L", 8), ("XL", 5)],
            },
        ]
        for spec in specs:
            slug = unique_product_slug(spec["name"])
            p = Product.objects.create(
                name=spec["name"],
                slug=slug,
                description="Produk seed otomatis untuk pengujian checkout dan seller dashboard.",
                price=spec["price"],
                discount_price=spec["discount_price"],
                seller=user,
                category=category,
                color=spec["color"],
                is_new=True,
                is_active=True,
                moderation_flagged=False,
            )
            ProductImage.objects.create(
                product=p,
                image_url=DEMO_IMAGE,
                is_primary=True,
            )
            for size, stock in spec["sizes"]:
                sku = f"SEED-{p.pk}-{size}"
                ProductVariant.objects.create(
                    product=p,
                    size=size,
                    stock=stock,
                    sku=sku,
                )
            self.stdout.write(self.style.SUCCESS(f"  Produk: {p.name} (slug={p.slug})"))

    def _seed_buyer_demo(self, *, email: str, password: str, wallet_balance: int) -> User:
        buyer = User.objects.filter(email__iexact=email).first()
        if buyer:
            self.stdout.write(self.style.WARNING(f"Buyer sudah ada: {email} (id={buyer.pk})"))
            buyer.set_password(password)
            buyer.is_email_verified = True
            buyer.save(update_fields=["password", "is_email_verified"])
        else:
            buyer = User.objects.create_user(
                email=email,
                username=_username_for_email(email),
                password=password,
                auth_provider="email",
                is_email_verified=True,
                is_seller=False,
            )
            self.stdout.write(self.style.SUCCESS(f"Buyer dibuat: {email} (id={buyer.pk})"))

        # Keep exactly one primary address that is valid for checkout tests.
        addr, created = Address.objects.get_or_create(
            user=buyer,
            label="home",
            street_address="Jl. Demo No. 1",
            defaults={
                "recipient_name": "Buyer Demo",
                "phone_number": "081234567890",
                "city": "Bandung",
                "state": "Jawa Barat",
                "postal_code": "40123",
                "is_primary": True,
            },
        )
        if not created:
            addr.recipient_name = addr.recipient_name or "Buyer Demo"
            addr.phone_number = addr.phone_number or "081234567890"
            addr.city = addr.city or "Bandung"
            addr.state = addr.state or "Jawa Barat"
            addr.postal_code = addr.postal_code or "40123"
            addr.is_primary = True
            addr.save(
                update_fields=[
                    "recipient_name",
                    "phone_number",
                    "city",
                    "state",
                    "postal_code",
                    "is_primary",
                    "updated_at",
                ]
            )

        wallet, _ = Wallet.objects.get_or_create(user=buyer)
        wallet.balance = wallet_balance
        wallet.save(update_fields=["balance", "updated_at"])
        return buyer
