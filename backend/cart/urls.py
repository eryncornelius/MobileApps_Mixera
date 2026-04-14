from django.urls import path

from .views import CartShippingQuoteView, CartView, CartItemView, ClearCartView

urlpatterns = [
    path('shipping-quote/', CartShippingQuoteView.as_view(), name='cart-shipping-quote'),
    path('', CartView.as_view(), name='cart'),
    path('items/', CartItemView.as_view(), name='cart-items'),
    path('items/<int:pk>/', CartItemView.as_view(), name='cart-item-detail'),
    path('clear/', ClearCartView.as_view(), name='cart-clear'),
]
