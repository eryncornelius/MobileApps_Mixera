from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework.permissions import IsAuthenticated
from django.db.utils import OperationalError

from .models import Category, Product, WishlistItem
from .serializers import CategorySerializer, ProductListSerializer, ProductDetailSerializer


class CategoryListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        categories = Category.objects.all()
        return Response(CategorySerializer(categories, many=True).data)


class ProductListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        qs = (
            Product.objects.filter(is_active=True, moderation_flagged=False)
            .select_related('category')
            .prefetch_related('images', 'variants')
        )

        search = request.query_params.get('search')
        if search:
            qs = qs.filter(name__icontains=search)

        category = request.query_params.get('category')
        if category:
            qs = qs.filter(category__slug=category)

        if request.query_params.get('is_new') == 'true':
            qs = qs.filter(is_new=True)

        return Response(ProductListSerializer(qs, many=True, context={"request": request}).data)


class ProductDetailView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, slug):
        try:
            product = (
                Product.objects
                .prefetch_related('images', 'variants')
                .select_related('category', 'seller', 'seller__seller_profile')
                .get(slug=slug, is_active=True, moderation_flagged=False)
            )
        except Product.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=404)
        return Response(ProductDetailSerializer(product, context={"request": request}).data)


class WishlistListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            qs = (
                Product.objects.filter(
                    is_active=True,
                    moderation_flagged=False,
                    wishlist_items__user=request.user,
                )
                .select_related("category")
                .prefetch_related("images", "variants")
                .distinct()
                .order_by("-wishlist_items__created_at")
            )
            return Response(ProductListSerializer(qs, many=True, context={"request": request}).data)
        except OperationalError:
            # Safety fallback when migration is not applied yet.
            return Response([])


class WishlistToggleView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            product_id = request.data.get("product_id")
            if not product_id:
                return Response({"detail": "product_id wajib diisi."}, status=400)
            product = Product.objects.filter(
                pk=product_id,
                is_active=True,
                moderation_flagged=False,
            ).first()
            if not product:
                return Response({"detail": "Produk tidak ditemukan."}, status=404)
            row = WishlistItem.objects.filter(user=request.user, product=product).first()
            if row:
                row.delete()
                return Response({"is_wishlisted": False})
            WishlistItem.objects.create(user=request.user, product=product)
            return Response({"is_wishlisted": True})
        except OperationalError:
            return Response(
                {"detail": "Wishlist belum siap. Jalankan migrasi database terlebih dulu."},
                status=503,
            )
