from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),

    # User API (ini yang penting)
    path('api/users/', include('users.urls')),
    path("api/payments/", include("payments.urls")),
    path("api/wallet/", include("wallet.urls")),
    path("api/shop/", include("shop.urls")),
    path("api/cart/", include("cart.urls")),
    path("api/orders/", include("orders.urls")),
    # DEBUGGING PURPOSE
    # Wardrobe API
    path('api/wardrobe/', include('wardrobe.urls')),
]