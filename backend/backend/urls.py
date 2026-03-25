from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),

    # ini yang penting
    path('api/users/', include('users.urls')),
]