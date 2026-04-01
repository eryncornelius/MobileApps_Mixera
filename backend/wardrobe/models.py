from django.db import models
from django.contrib.auth.models import User

# Create your models here.
categoryOutfit = [
    ('outer', 'Outer'),
    ('top', 'Top'),
    ('bags', 'Bags'),
    ('accessories', 'Accessories'),
    ('shoes', 'Shoes'),
    ('dresses', 'Dresses'),
]

class WardrobeItem(models.Model):
    id = models.AutoField(primary_key=True)
    # user = models.ForeignKey(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=255)
    category = models.CharField(max_length=255, choices=categoryOutfit)
    favorite = models.BooleanField(default=False)
    img = models.ImageField(("Image"), upload_to=None, max_length=100)

    def __str__(self):
        return self.name 





