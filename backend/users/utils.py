from email.utils import formataddr, parseaddr
from django.core.mail import EmailMultiAlternatives
from django.conf import settings


def send_otp_email(email, code):
    subject = 'Your Mixera Verification Code'
    raw_from = getattr(settings, 'DEFAULT_FROM_EMAIL', 'noreply@mixera.com')
    _, raw_addr = parseaddr(raw_from)  # strips any existing display name
    from_email = formataddr(('Mixera', raw_addr))

    text_body = (
        f'Your Mixera verification code is: {code}\n\n'
        'This code expires in 5 minutes. Do not share it with anyone.\n\n'
        'If you did not request this, please ignore this email.\n\n'
        '— The Mixera Team'
    )

    html_body = f"""
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Mixera Verification Code</title>
</head>
<body style="margin:0;padding:0;background-color:#f9f0f2;font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;">

  <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f9f0f2;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="560" cellpadding="0" cellspacing="0" style="max-width:560px;width:100%;">

          <!-- Header -->
          <tr>
            <td align="center" style="background-color:#2e2e2e;border-radius:12px 12px 0 0;padding:32px 40px;">
              <p style="margin:0;font-size:28px;font-weight:700;letter-spacing:6px;color:#f4b6c2;font-family:Georgia,'Times New Roman',serif;">
                MIXÉRA
              </p>
              <p style="margin:8px 0 0;font-size:12px;letter-spacing:2px;color:#aaaaaa;text-transform:uppercase;">
                Secure Verification
              </p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="background-color:#ffffff;padding:40px 40px 32px;">

              <p style="margin:0 0 8px;font-size:22px;font-weight:700;color:#2e2e2e;">
                Verification Code
              </p>
              <p style="margin:0 0 28px;font-size:14px;color:#6b6b6b;line-height:1.6;">
                Use the code below to verify your identity. This code is valid for
                <strong style="color:#2e2e2e;">5 minutes</strong> and can only be used once.
              </p>

              <!-- OTP Box -->
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td align="center" style="background-color:#fff5f7;border:2px solid #f4b6c2;border-radius:12px;padding:28px 20px;">
                    <p style="margin:0 0 6px;font-size:11px;letter-spacing:2px;text-transform:uppercase;color:#aaaaaa;">
                      Your one-time code
                    </p>
                    <p style="margin:0;font-size:48px;font-weight:800;letter-spacing:18px;color:#2e2e2e;font-family:'Courier New',Courier,monospace;">
                      {code}
                    </p>
                  </td>
                </tr>
              </table>

              <p style="margin:28px 0 0;font-size:13px;color:#6b6b6b;line-height:1.7;">
                If you did not request this code, you can safely ignore this email.
                Your account remains secure and no changes have been made.
              </p>

            </td>
          </tr>

          <!-- Divider -->
          <tr>
            <td style="background-color:#ffffff;padding:0 40px;">
              <hr style="border:none;border-top:1px solid #e6e6e6;margin:0;" />
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color:#ffffff;border-radius:0 0 12px 12px;padding:24px 40px 32px;">
              <p style="margin:0;font-size:12px;color:#aaaaaa;line-height:1.8;">
                This is an automated message from <strong style="color:#6b6b6b;">Mixera</strong>.
                Please do not reply to this email.<br/>
                &copy; 2025 Mixera. All rights reserved.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>

</body>
</html>
"""

    print(f"[OTP DEBUG] Email: {email} | Code: {code}")

    try:
        msg = EmailMultiAlternatives(subject, text_body, from_email, [email])
        msg.attach_alternative(html_body, "text/html")
        msg.send(fail_silently=False)
    except Exception as e:
        print(f"[EMAIL ERROR] Failed to send OTP: {e}")
        raise e
