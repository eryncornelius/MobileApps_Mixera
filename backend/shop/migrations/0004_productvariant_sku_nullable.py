from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('shop', '0003_product_moderation'),
    ]

    operations = [
        migrations.AlterField(
            model_name='productvariant',
            name='sku',
            field=models.CharField(blank=True, max_length=100, null=True, unique=True),
        ),
    ]
