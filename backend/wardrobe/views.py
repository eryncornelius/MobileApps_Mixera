from django.shortcuts import render
from .models import WardrobeItem
from .serializers import WardrobeItemSerializer
from rest_framework import viewsets

# Create your views here.
class WardrobeItemViewSet(viewsets.ModelViewSet):
    queryset = WardrobeItem.objects.all()
    serializer_class = WardrobeItemSerializer








