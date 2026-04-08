from django.db.models import Q
from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import Product, RecentSearch, RecentlyViewed
from .serializers import (
    ProductSerializer,
    RecentSearchSerializer,
    RecentlyViewedSerializer,
)


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


class RecentSearchListCreateView(generics.ListCreateAPIView):
    serializer_class = RecentSearchSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return RecentSearch.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        query = serializer.validated_data.get('query')
        RecentSearch.objects.filter(user=self.request.user, query__iexact=query).delete()
        serializer.save(user=self.request.user)


class RecentlyViewedListCreateView(generics.ListCreateAPIView):
    serializer_class = RecentlyViewedSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return RecentlyViewed.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        product = serializer.validated_data.get('product')
        RecentlyViewed.objects.filter(user=self.request.user, product=product).delete()
        serializer.save(user=self.request.user)
