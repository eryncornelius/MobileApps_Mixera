# Generated manually for M1 Core API migration

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("payments", "0001_initial"),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AddField(
            model_name="paymenttransaction",
            name="payment_method_type",
            field=models.CharField(
                blank=True,
                choices=[("snap", "Snap"), ("card", "Card")],
                max_length=20,
                null=True,
            ),
        ),
        migrations.AddField(
            model_name="paymenttransaction",
            name="linked_order_id",
            field=models.PositiveIntegerField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name="paymenttransaction",
            name="purpose",
            field=models.CharField(
                choices=[("wallet_topup", "Wallet Top Up"), ("shop_order", "Shop Order")],
                max_length=30,
            ),
        ),
        migrations.AlterModelOptions(
            name="paymenttransaction",
            options={"ordering": ["-created_at"]},
        ),
        migrations.CreateModel(
            name="SavedCard",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("card_brand", models.CharField(blank=True, max_length=50)),
                ("masked_card", models.CharField(blank=True, max_length=20)),
                ("saved_token_id", models.CharField(max_length=255, unique=True)),
                ("is_default", models.BooleanField(default=False)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                (
                    "user",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="saved_cards",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
            options={"ordering": ["-created_at"]},
        ),
    ]
