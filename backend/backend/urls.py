from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),

    # User API (ini yang penting)
    path('api/users/', include('users.urls')),
    

    # DEBUGGING PURPOSE
    # Wardrobe API
    path('api/wardrobe/', include('wardrobe.urls')),
    path('api/shop/', include('shop.urls')),
]