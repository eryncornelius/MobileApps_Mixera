from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("shop", "0002_product_seller"),
    ]

    operations = [
        migrations.AddField(
            model_name="product",
            name="moderation_flagged",
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name="product",
            name="moderation_note",
            field=models.TextField(blank=True),
        ),
    ]
