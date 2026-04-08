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


class RecentSearch(models.Model):
    user = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='recent_searches')
    query = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        unique_together = ('user', 'query')

    def __str__(self):
        return f"{self.user.email} - {self.query}"


class RecentlyViewed(models.Model):
    user = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='recently_viewed')
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='viewed_by')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        unique_together = ('user', 'product')

    def __str__(self):
        return f"{self.user.email} viewed {self.product.name}"
