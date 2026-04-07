from django.db import models

class Product(models.Model):
    CATEGORY_CHOICES = [
        ('New', 'New'),
        ('Tops', 'Tops'),
        ('Bottoms', 'Bottoms'),
        ('Dress', 'Dress'),
    ]
    
    name = models.CharField(max_length=200)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES)
    image_url = models.ImageField(upload_to='shop/')

    def __str__(self):
        return self.name
