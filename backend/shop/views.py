from django.db.models import Q
from rest_framework import generics
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import Product
from .serializers import ProductSerializer


class ProductListView(generics.ListAPIView):
    serializer_class = ProductSerializer

    def get_queryset(self):
        queryset = Product.objects.all()
        category = self.request.query_params.get('category')
        search = self.request.query_params.get('search')

        if category:
            queryset = queryset.filter(category__iexact=category)

        if search:
            queryset = queryset.filter(
                Q(name__icontains=search) | Q(category__icontains=search)
            )

        return queryset


class ProductDetailView(generics.RetrieveAPIView):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer


class CategoryChoicesView(APIView):
    def get(self, request):
        choices = [{'value': choice[0], 'label': choice[1]} for choice in Product.CATEGORY_CHOICES]
        return Response(choices)


class PopularSearchesView(APIView):
    def get(self, request):
        popular_searches = [
            'Midi skirt',
            'Blouse',
            'Sweater',
            'Cute Tops',
            'Dress',
            'Floral Dress',
            'Crop Tops',
            'Pastel',
            'Pink',
        ]
        return Response({'popular_searches': popular_searches})
