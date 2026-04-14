import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("orders", "0002_alter_order_payment_method"),
        ("shop", "0002_product_seller"),
    ]

    operations = [
        migrations.AddField(
            model_name="order",
            name="tracking_number",
            field=models.CharField(blank=True, max_length=120),
        ),
        migrations.AddField(
            model_name="order",
            name="shipping_courier",
            field=models.CharField(blank=True, max_length=80),
        ),
        migrations.AddField(
            model_name="orderitem",
            name="variant",
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.SET_NULL,
                related_name="order_items",
                to="shop.productvariant",
            ),
        ),
    ]
