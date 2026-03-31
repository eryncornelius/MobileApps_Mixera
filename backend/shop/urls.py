from django.urls import path

from .views import CategoryListView, ProductListView, ProductDetailView

urlpatterns = [
    path('categories/', CategoryListView.as_view(), name='shop-categories'),
    path('products/', ProductListView.as_view(), name='shop-products'),
    path('products/<slug:slug>/', ProductDetailView.as_view(), name='shop-product-detail'),
]
