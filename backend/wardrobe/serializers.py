from rest_framework import serializers
from .models import WardrobeItem

class WardrobeItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = WardrobeItem
        fields = ['id', 'name', 'category', 'favorite', 'img']


    
