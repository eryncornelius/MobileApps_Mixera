from django.db import migrations, models


def forwards_status_values(apps, schema_editor):
    Order = apps.get_model("orders", "Order")
    Order.objects.filter(status="completed").update(status="delivered")
    Order.objects.filter(status="cancelled").update(status="canceled")


def reverse_status_values(apps, schema_editor):
    Order = apps.get_model("orders", "Order")
    Order.objects.filter(status="delivered").update(status="completed")
    Order.objects.filter(status="canceled").update(status="cancelled")


class Migration(migrations.Migration):
    dependencies = [
        ("orders", "0003_order_shipping_orderitem_variant"),
    ]

    operations = [
        migrations.AlterField(
            model_name="order",
            name="status",
            field=models.CharField(
                max_length=20,
                choices=[
                    ("pending", "Pending"),
                    ("paid", "Paid"),
                    ("processing", "Processing"),
                    ("shipped", "Shipped"),
                    ("completed", "Completed"),
                    ("cancelled", "Cancelled"),
                    ("delivered", "Delivered"),
                    ("canceled", "Canceled"),
                ],
                default="pending",
            ),
        ),
        migrations.RunPython(forwards_status_values, reverse_status_values),
        migrations.AlterField(
            model_name="order",
            name="status",
            field=models.CharField(
                max_length=20,
                choices=[
                    ("pending", "Pending"),
                    ("paid", "Paid"),
                    ("processing", "Processing"),
                    ("shipped", "Shipped"),
                    ("delivered", "Delivered"),
                    ("canceled", "Canceled"),
                ],
                default="pending",
            ),
        ),
    ]
