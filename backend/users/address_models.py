class Address(models.Model):
    LABEL_CHOICES = (
        ("home", "Home"),
        ("work", "Work"),
        ("other", "Other"),
    )

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="addresses",
    )
    label = models.CharField(max_length=20, choices=LABEL_CHOICES, default="home")
    recipient_name = models.CharField(max_length=255)
    phone_number = models.CharField(max_length=20)
    street_address = models.TextField()
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    postal_code = models.CharField(max_length=20)
    is_primary = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-is_primary", "-updated_at"]

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)

        if self.is_primary:
            Address.objects.filter(user=self.user).exclude(id=self.id).update(
                is_primary=False
            )

    def __str__(self):
        return f"{self.user.email} - {self.label}"