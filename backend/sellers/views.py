import csv
import io
import logging
import uuid
from datetime import datetime

from django.conf import settings
from django.contrib.auth import get_user_model
from django.core.files.base import ContentFile
from django.core.files.storage import default_storage
from django.db import transaction as db_transaction
from rest_framework import status
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from orders.models import Order
from shop.models import Category, Product, ProductImage, ProductVariant
from shop.serializers import ProductDetailSerializer, ProductListSerializer

from .models import (
    SellerChannelListing,
    SellerNotification,
    SellerOrderEarning,
    SellerPayoutRequest,
    SellerProfile,
)
from .permissions import IsApprovedSeller
from .renderers import CsvTextRenderer
from .serializers import (
    SellerChannelCreateSerializer,
    SellerChannelListingSerializer,
    SellerMeSerializer,
    SellerNotificationSerializer,
    SellerOrderDetailSerializer,
    SellerOrderEarningSerializer,
    SellerOrderListSerializer,
    SellerOrderUpdateSerializer,
    SellerPayoutCreateSerializer,
    SellerPayoutSerializer,
    SellerProductImageUploadSerializer,
    SellerProductPatchSerializer,
    SellerProductWriteSerializer,
    SellerProfileSerializer,
    ShippingQuoteSerializer,
)
from users.notifications import notify_user
from .services.balance import seller_available_balance
from .services.product_slug import unique_product_slug, unique_product_slug_for_update
from .services.seller_order_query import orders_for_seller, seller_has_order
from .services.shipping_origin import origin_postal_from_seller_user, settings_fallback_origin
from .services.shipping_rates import resolve_shipping_quotes

logger = logging.getLogger("mixera.sellers")


class SellerMeView(APIView):
    permission_classes = [IsAuthenticated, IsApprovedSeller]

    def get(self, request):
        profile = getattr(request.user, "seller_profile", None)
        data = {
            "store_name": profile.store_name if profile else "",
            "ship_from_postal_code": profile.ship_from_postal_code if profile else "",
        }
        data["is_seller"] = request.user.is_seller
        return Response(data)

    def patch(self, request):
        ser = SellerMeSerializer(data=request.data, partial=True)
        ser.is_valid(raise_exception=True)
        profile, _ = SellerProfile.objects.get_or_create(user=request.user)
        update_fields = ["updated_at"]
        if "store_name" in ser.validated_data:
            profile.store_name = ser.validated_data["store_name"]
            update_fields.append("store_name")
        if "ship_from_postal_code" in ser.validated_data:
            profile.ship_from_postal_code = ser.validated_data["ship_from_postal_code"]
            update_fields.append("ship_from_postal_code")
        profile.save(update_fields=update_fields)
        return Response(
            SellerProfileSerializer(profile).data,
            status=status.HTTP_200_OK,
        )


class SellerProductListCreateView(APIView):
    permission_classes = [IsAuthenticated, IsApprovedSeller]

    def get(self, request):
        qs = (
            Product.objects.filter(seller=request.user)
            .select_related("category")
            .prefetch_related("images", "variants")
            .order_by("-created_at")
        )
        return Response(ProductListSerializer(qs, many=True).data)

    def post(self, request):
        ser = SellerProductWriteSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        d = ser.validated_data
        category = None
        if d.get("category_id"):
            category = Category.objects.filter(pk=d["category_id"]).first()

        slug = unique_product_slug(d["name"])
        with db_transaction.atomic():
            product = Product.objects.create(
                name=d["name"],
                slug=slug,
                description=d.get("description") or "",
                price=d["price"],
                discount_price=d.get("discount_price"),
                category=category,
                color=d.get("color") or "",
                seller=request.user,
                is_active=True,
            )
            rows = d.get("variants")
            if rows:
                for row in rows:
                    ProductVariant.objects.create(
                        product=product,
                        size=row["size"],
                        stock=row["stock"],
                        sku=None,
                    )
            else:
                ProductVariant.objects.create(
                    product=product,
                    size=d["size"],
                    stock=d["stock"],
                    sku=None,
                )
            url = (d.get("image_url") or "").strip()
            if url:
                ProductImage.objects.create(
                    product=product,
                    image_url=url,
                    is_primary=True,
                )
        qs = (
            Product.objects.filter(pk=product.pk)
            .select_related("category")
            .prefetch_related("images", "variants")
        )
        return Response(ProductListSerializer(qs.first()).data, status=status.HTTP_201_CREATED)


_UPLOAD_CTYPES = {
    "image/jpeg": ".jpg",
    "image/jpg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
}


class SellerProductImageUploadView(APIView):
    permission_classes = [IsAuthenticated, IsApprovedSeller]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        ser = SellerProductImageUploadSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        img = ser.validated_data["image"]
        ct = (getattr(img, "content_type", None) or "").split(";")[0].strip().lower()
        ext = _UPLOAD_CTYPES.get(ct)
        if not ext:
            return Response(
                {"detail": "Format tidak didukung. Gunakan JPEG, PNG, atau WebP."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        path = f"seller_products/{request.user.id}/{uuid.uuid4().hex}{ext}"
        saved = default_storage.save(path, ContentFile(img.read()))
        rel_url = default_storage.url(saved)
        if rel_url.startswith("http"):
            full_url = rel_url
        else:
            public_base = getattr(settings, "BACKEND_PUBLIC_URL", "").strip()
            base = public_base if public_base else request.build_absolute_uri("/").rstrip("/")
            full_url = f"{base}{rel_url}"
        return Response({"url": full_url})


class SellerProductDetailView(APIView):
    permission_classes = [IsAuthenticated, IsApprovedSeller]

    def get(self, request, pk):
        try:
            product = (
                Product.objects.filter(pk=pk, seller=request.user)
                .select_related("category")
                .prefetch_related("images", "variants")
                .get()
            )
        except Product.DoesNotExist:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        return Response(ProductDetailSerializer(product).data)

    def patch(self, request, pk):
        try:
            product = Product.objects.get(pk=pk, seller=request.user)
        except Product.DoesNotExist:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)

        ser = SellerProductPatchSerializer(data=request.data, partial=True)
        ser.is_valid(raise_exception=True)
        d = ser.validated_data
        fields = []
        if "name" in d:
            new_name = d["name"]
            if new_name != product.name:
                product.name = new_name
                product.slug = unique_product_slug_for_update(new_name, product.pk)
                fields.extend(["name", "slug"])
        if "description" in d:
            product.description = d["description"]
            fields.append("description")
        if "price" in d:
            product.price = d["price"]
            fields.append("price")
        if "discount_price" in d:
            product.discount_price = d["discount_price"]
            fields.append("discount_price")
        if "color" in d:
            product.color = d["color"]
            fields.append("color")
        if "is_active" in d:
            product.is_active = d["is_active"]
            fields.append("is_active")
        if fields:
            fields.append("updated_at")
            product.save(update_fields=fields)
        variant_rows = d.get("variant_stocks")
        if variant_rows:
            for row in variant_rows:
                v = ProductVariant.objects.filter(pk=row["variant_id"], product=product).first()
                if v:
                    v.stock = row["stock"]
                    v.save(update_fields=["stock"])
        elif "stock" in d:
            v = product.variants.first()
            if v:
                v.stock = d["stock"]
                v.save(update_fields=["stock"])
        for row in d.get("variants_add") or []:
            if ProductVariant.objects.filter(product=product, size=row["size"]).exists():
                return Response(
                    {"detail": f"Ukuran {row['size']} sudah ada."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            ProductVariant.objects.create(
                product=product,
                size=row["size"],
                stock=row["stock"],
                sku=None,
            )
        if "image_url" in d:
            url = (d.get("image_url") or "").strip()
            if url:
                ProductImage.objects.filter(product=product, is_primary=True).delete()
                ProductImage.objects.create(
                    product=product,
                    image_url=url,
                    is_primary=True,
                )
        qs = (
            Product.objects.filter(pk=product.pk)
            .select_related("category")
            .prefetch_related("images", "variants")
        )
        return Response(ProductListSerializer(qs.first()).data)


class SellerOrderListView(APIView):
    permission_classes = [IsAuthenticated, IsApprovedSeller]

    def get(self, request):
        qs = orders_for_seller(request.user)
        st = request.query_params.get("status")
        if st:
            qs = qs.filter(status=st)
        return Response(
            SellerOrderListSerializer(qs, many=True, context={"seller": request.user}).data
        )


class SellerOrderDetailView(APIView):
    permission_classes = [IsAuthenticated, IsApprovedSeller]

    def get(self, request, pk):
        try:
            order = Order.objects.prefetch_related("items__variant__product").get(pk=pk)
        except Order.DoesNotExist:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        if not seller_has_order(request.user, order):
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        return Response(
            SellerOrderDetailSerializer(order, context={"seller": request.user}).data
        )

    def patch(self, request, pk):
        try:
            order = Order.objects.get(pk=pk)
        except Order.DoesNotExist:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        if not seller_has_order(request.user, order):
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)

        ser = SellerOrderUpdateSerializer(data=request.data, partial=True)
        ser.is_valid(raise_exception=True)
        d = ser.validated_data

        if order.payment_status != "paid":
            return Response(
                {"detail": "Order is not paid yet."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if "tracking_number" in d:
            order.tracking_number = d["tracking_number"]
        if "shipping_courier" in d:
            order.shipping_courier = d["shipping_courier"]
        if "status" in d:
            new_st = d["status"]
            if new_st == "shipped":
                if order.status != "processing":
                    return Response(
                        {"detail": "Can only mark shipped from processing."},
                        status=status.HTTP_400_BAD_REQUEST,
                    )
                tracking = (order.tracking_number or "").strip()
                if not tracking:
                    return Response(
                        {"detail": "Nomor resi wajib sebelum menandai dikirim."},
                        status=status.HTTP_400_BAD_REQUEST,
                    )
                order.status = "shipped"
            elif new_st in ("completed", "delivered"):
                if order.status != "shipped":
                    return Response(
                        {"detail": "Can only mark delivered from shipped."},
                        status=status.HTTP_400_BAD_REQUEST,
                    )
                order.status = "delivered"

        update_fields = []
        _prev_status = order.status  # captured before save for notification trigger
        if "tracking_number" in d:
            update_fields.append("tracking_number")
        if "shipping_courier" in d:
            update_fields.append("shipping_courier")
        if "status" in d:
            update_fields.append("status")
        if update_fields:
            update_fields.append("updated_at")
            order.save(update_fields=update_fields)

        # Notify buyer on status change
        if "status" in d:
            _notify_buyer_order_status(order)

        return Response(
            SellerOrderDetailSerializer(order, context={"seller": request.user}).data
        )


class SellerDashboardView(APIView):
    permission_classes = [IsAuthenticated, IsApprovedSeller]

    def get(self, request):
        user = request.user
        qs_orders = orders_for_seller(user)
        qs_products = Product.objects.filter(seller=user).prefetch_related("variants")
        low = 0
        for p in qs_products:
            vl = list(p.variants.all())
            if not vl or any(v.stock < 5 for v in vl):
                low += 1
        return Response(
            {
                "product_count": qs_products.count(),
                "order_count": qs_orders.count(),
                "processing_count": qs_orders.filter(status="processing").count(),
                "shipped_count": qs_orders.filter(status="shipped").count(),
                "completed_count": qs_orders.filter(status="delivered").count(),
                "low_stock_count": low,
                "available_balance": seller_available_balance(user),
                "unread_notifications": SellerNotification.objects.filter(
                    seller=user, is_read=False
                ).count(),
            }
        )


class SellerFinanceEarningsView(APIView):
    permission_classes = [IsAuthenticated, IsApprovedSeller]

    def get(self, request):
        qs = SellerOrderEarning.objects.filter(seller=request.user).select_related("order")
        df = request.query_params.get("from")
        dto = request.query_params.get("to")
        if df:
            try:
                d0 = datetime.strptime(df, "%Y-%m-%d").date()
                qs = qs.filter(created_at__date__gte=d0)
            except ValueError:
                pass
        if dto:
            try:
                d1 = datetime.strptime(dto, "%Y-%m-%d").date()
                qs = qs.filter(created_at__date__lte=d1)
            except ValueError:
                pass
        return Response(SellerOrderEarningSerializer(qs.order_by("-created_at")[:500], many=True).data)


class SellerFinancePayoutsView(APIView):
    permission_classes = [IsAuthenticated, IsApprovedSeller]

    def get(self, request):
        qs = SellerPayoutRequest.objects.filter(seller=request.user)
        return Response(SellerPayoutSerializer(qs, many=True).data)

    def post(self, request):
        ser = SellerPayoutCreateSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        amount = ser.validated_data["amount"]
        User = get_user_model()
        with db_transaction.atomic():
            # Serialize concurrent payout requests per seller (double-tap / retries).
            User.objects.select_for_update().get(pk=request.user.pk)
            avail = seller_available_balance(request.user)
            if amount > avail:
                return Response(
                    {"detail": "Jumlah melebihi saldo yang bisa dicairkan."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            p = SellerPayoutRequest.objects.create(seller=request.user, amount=amount)
        logger.info("payout_requested seller=%s amount=%s", request.user.pk, amount)
        return Response(SellerPayoutSerializer(p).data, status=status.HTTP_201_CREATED)


class SellerFinanceEarningsExportView(APIView):
    permission_classes = [IsAuthenticated, IsApprovedSeller]
    renderer_classes = [CsvTextRenderer]

    def get(self, request):
        qs = (
            SellerOrderEarning.objects.filter(seller=request.user)
            .select_related("order")
            .order_by("-created_at")[:2000]
        )
        buf = io.StringIO()
        w = csv.writer(buf)
        w.writerow(["id", "order_id", "gross", "fee", "net", "created_at"])
        for e in qs:
            w.writerow(
                [
                    e.id,
                    e.order_id,
                    e.item_subtotal_gross,
                    e.platform_fee,
                    e.net_to_seller,
                    e.created_at.isoformat(),
                ]
            )
        return Response(
            buf.getvalue(),
            content_type="text/csv; charset=utf-8",
            headers={"Content-Disposition": 'attachment; filename="mixera_seller_earnings.csv"'},
        )


class SellerNotificationsView(APIView):
    permission_classes = [IsAuthenticated, IsApprovedSeller]

    def get(self, request):
        qs = SellerNotification.objects.filter(seller=request.user)[:100]
        return Response(SellerNotificationSerializer(qs, many=True).data)


class SellerNotificationsReadView(APIView):
    permission_classes = [IsAuthenticated, IsApprovedSeller]

    def post(self, request):
        if request.data.get("all"):
            SellerNotification.objects.filter(seller=request.user, is_read=False).update(is_read=True)
            return Response({"marked": "all"})
        nid = request.data.get("id")
        if not nid:
            return Response({"detail": "id or all required."}, status=status.HTTP_400_BAD_REQUEST)
        SellerNotification.objects.filter(pk=nid, seller=request.user).update(is_read=True)
        return Response({"marked": nid})


class SellerShippingQuoteView(APIView):
    permission_classes = [IsAuthenticated, IsApprovedSeller]

    def post(self, request):
        ser = ShippingQuoteSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        d = ser.validated_data
        origin_pc = origin_postal_from_seller_user(request.user) or settings_fallback_origin()
        quotes, note = resolve_shipping_quotes(
            weight_grams=d["weight_grams"],
            destination_city=d.get("destination_city") or "",
            destination_postal_code=d.get("destination_postal_code") or "",
            origin_postal_code=origin_pc,
        )
        return Response({"quotes": quotes, "note": note})


class SellerChannelListingView(APIView):
    permission_classes = [IsAuthenticated, IsApprovedSeller]

    def get(self, request):
        qs = SellerChannelListing.objects.filter(seller=request.user).select_related("product")
        return Response(SellerChannelListingSerializer(qs, many=True).data)

    def post(self, request):
        ser = SellerChannelCreateSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        d = ser.validated_data
        try:
            product = Product.objects.get(pk=d["product_id"], seller=request.user)
        except Product.DoesNotExist:
            return Response({"detail": "Product not found."}, status=status.HTTP_404_NOT_FOUND)
        row, _ = SellerChannelListing.objects.update_or_create(
            seller=request.user,
            product=product,
            channel=d["channel"],
            defaults={
                "external_id": "",
                "sync_status": SellerChannelListing.SyncStatus.PENDING,
                "last_error": "Integrasi API channel belum aktif (stub).",
            },
        )
        return Response(SellerChannelListingSerializer(row).data, status=status.HTTP_201_CREATED)


def _notify_buyer_order_status(order):
    """Send in-app + push notification to buyer when seller updates order status."""
    _STATUS_MESSAGES = {
        "processing": ("Pesanan Sedang Diproses", "Pesanan #{id} sedang disiapkan oleh penjual."),
        "shipped": ("Pesanan Dikirim", "Pesanan #{id} telah dikirim. Cek nomor resi di detail pesanan."),
        "delivered": ("Pesanan Selesai", "Pesanan #{id} telah selesai. Terima kasih sudah berbelanja!"),
        "canceled": ("Pesanan Dibatalkan", "Pesanan #{id} telah dibatalkan."),
    }
    msg = _STATUS_MESSAGES.get(order.status)
    if not msg:
        return
    title, body_tpl = msg
    body = body_tpl.format(id=order.pk)
    notify_user(
        order.user,
        notif_type='order',
        title=title,
        body=body,
        payload={'order_id': order.pk, 'status': order.status},
    )
