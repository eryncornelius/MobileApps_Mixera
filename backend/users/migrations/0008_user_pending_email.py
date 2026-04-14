from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("users", "0007_usernotification_fcmtoken"),
    ]

    operations = [
        migrations.AddField(
            model_name="user",
            name="pending_email",
            field=models.EmailField(
                blank=True,
                help_text="Email baru menunggu verifikasi OTP sebelum dipindah ke email.",
                max_length=254,
                null=True,
            ),
        ),
    ]
