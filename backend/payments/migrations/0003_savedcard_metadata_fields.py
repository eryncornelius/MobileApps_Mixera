from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("payments", "0002_savedcard_paymenttransaction_linked_order_id_and_more"),
    ]

    operations = [
        migrations.AddField(
            model_name="savedcard",
            name="card_type",
            field=models.CharField(blank=True, max_length=30),
        ),
        migrations.AddField(
            model_name="savedcard",
            name="expiry_month",
            field=models.CharField(blank=True, max_length=2),
        ),
        migrations.AddField(
            model_name="savedcard",
            name="expiry_year",
            field=models.CharField(blank=True, max_length=4),
        ),
    ]
