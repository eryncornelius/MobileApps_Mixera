from django.urls import path
from .views import ProductListView, ProductDetailView, CategoryChoicesView, PopularSearchesView

urlpatterns = [
    path('products/', ProductListView.as_view(), name='product-list'),
    path('products/<int:pk>/', ProductDetailView.as_view(), name='product-detail'),
    path('categories/', CategoryChoicesView.as_view(), name='category-choices'),
    path('popular-searches/', PopularSearchesView.as_view(), name='popular-searches'),
]
