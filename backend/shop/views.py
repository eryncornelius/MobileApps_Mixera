from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny

from .models import Category, Product
from .serializers import CategorySerializer, ProductListSerializer, ProductDetailSerializer


class CategoryListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        categories = Category.objects.all()
        return Response(CategorySerializer(categories, many=True).data)


class ProductListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        qs = Product.objects.filter(is_active=True).select_related('category').prefetch_related('images')

        search = request.query_params.get('search')
        if search:
            qs = qs.filter(name__icontains=search)

        category = request.query_params.get('category')
        if category:
            qs = qs.filter(category__slug=category)

        if request.query_params.get('is_new') == 'true':
            qs = qs.filter(is_new=True)

        return Response(ProductListSerializer(qs, many=True).data)


class ProductDetailView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, slug):
        try:
            product = (
                Product.objects
                .prefetch_related('images', 'variants')
                .select_related('category')
                .get(slug=slug, is_active=True)
            )
        except Product.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=404)
        return Response(ProductDetailSerializer(product).data)
