from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("tryon", "0004_tryonresult_is_saved"),
    ]

    operations = [
        migrations.AddField(
            model_name="personprofileimage",
            name="is_archived",
            field=models.BooleanField(
                db_index=True,
                default=False,
                help_text="Hidden from picker; row kept for TryOnRequest FK (PROTECT).",
            ),
        ),
    ]
