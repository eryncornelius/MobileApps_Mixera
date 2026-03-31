from django.urls import path

from .views import (
    WardrobeItemViewSet,
)

urlpatterns = [
    path('list/', WardrobeItemViewSet.as_view({'get': 'list'})),
    path('upload/', WardrobeItemViewSet.as_view({'post': 'create'})),

]