from django.urls import path

from .views import CheckoutView, OrderListView, OrderDetailView, OrderTrackingView

urlpatterns = [
    path('checkout/', CheckoutView.as_view(), name='checkout'),
    path('', OrderListView.as_view(), name='orders'),
    path('<int:pk>/', OrderDetailView.as_view(), name='order-detail'),
    path('<int:pk>/tracking/', OrderTrackingView.as_view(), name='order-tracking'),
]
