from django.core.mail import send_mail
from django.conf import settings


def send_otp_email(email, code):
    subject = 'MIXÉRA - Your Verification Code'
    message = (
        f'Your 4-digit verification code is: {code}\n\n'
        'This code will expire in 5 minutes. Do not share this code with anyone.'
    )
    from_email = getattr(settings, 'DEFAULT_FROM_EMAIL', 'noreply@mixera.com')

    # DEBUG (biar tetap kelihatan di terminal)
    print(f"[OTP DEBUG] Email: {email} | Code: {code}")

    try:
        send_mail(
            subject,
            message,
            from_email,
            [email],
            fail_silently=False
        )
    except Exception as e:
        print(f"[EMAIL ERROR] Failed to send OTP: {e}")
        raise e  # biar tetap kelihatan di API response