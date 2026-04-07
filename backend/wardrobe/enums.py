from django.db import models


class BatchStatus(models.TextChoices):
    PENDING = "pending", "Pending"
    PROCESSING = "processing", "Processing"
    REVIEW_READY = "review_ready", "Review Ready"
    CONFIRMED = "confirmed", "Confirmed"
    FAILED = "failed", "Failed"


class ClothingCategory(models.TextChoices):
    TOP = "top", "Top"
    BOTTOM = "bottom", "Bottom"
    OUTER = "outer", "Outer"
    DRESS = "dress", "Dress"
    SHOES = "shoes", "Shoes"
    BAG = "bag", "Bag"
    ACCESSORIES = "accessories", "Accessories"
    OTHER = "other", "Other"
