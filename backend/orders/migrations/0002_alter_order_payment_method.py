# Generated manually for M2 — rename payment_method choice midtrans → card

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("orders", "0001_initial"),
    ]

    operations = [
        migrations.AlterField(
            model_name="order",
            name="payment_method",
            field=models.CharField(
                choices=[("wallet", "Wallet"), ("card", "Card")],
                max_length=20,
            ),
        ),
    ]
