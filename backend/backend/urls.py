from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),

    # ini yang penting
    path("api/wardrobe/", include("wardrobe.urls")),
    path("api/mixmatch/", include("mixmatch.urls")),
    path("api/tryon/", include("tryon.urls")),
    path('api/users/', include('users.urls')),
    path("api/payments/", include("payments.urls")),
    path("api/wallet/", include("wallet.urls")),
    path("api/shop/", include("shop.urls")),
    path("api/cart/", include("cart.urls")),
    path("api/orders/", include("orders.urls")),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
