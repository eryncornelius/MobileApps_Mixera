from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("sellers", "0002_finance_notifications_channel"),
    ]

    operations = [
        migrations.AddField(
            model_name="sellerprofile",
            name="ship_from_postal_code",
            field=models.CharField(blank=True, max_length=10),
        ),
    ]
