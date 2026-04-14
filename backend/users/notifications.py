"""
Notification helper — creates UserNotification records and optionally
sends FCM push if FIREBASE_SERVICE_ACCOUNT_JSON is configured in settings.

Usage:
    from users.notifications import notify_user
    notify_user(user, 'order', 'Pesanan Dikonfirmasi', 'Order #12 sedang diproses.', payload={'order_id': 12})
"""
import logging

from django.conf import settings

logger = logging.getLogger("mixera.notifications")

# Map notif_type → NotificationSettings field name (None = always send)
_SETTINGS_MAP = {
    'order': 'order_updates',
    'promo': 'promotions',
    'security': 'security_alerts',
    'reminder': 'daily_reminders',
    'system': None,
}


def notify_user(user, notif_type: str, title: str, body: str, payload: dict | None = None):
    """
    Create a UserNotification for *user* and fire an FCM push if possible.
    Returns the created UserNotification, or None if the user disabled that type.
    """
    from .models import NotificationSettings, UserNotification

    # Respect NotificationSettings toggles
    field = _SETTINGS_MAP.get(notif_type)
    if field:
        try:
            ns = NotificationSettings.objects.get(user=user)
            if not getattr(ns, field, True):
                return None
        except NotificationSettings.DoesNotExist:
            pass  # default = enabled

    notif = UserNotification.objects.create(
        user=user,
        notif_type=notif_type,
        title=title,
        body=body,
        payload=payload or {},
    )

    _send_fcm(user, title, body, payload or {})
    return notif


def _send_fcm(user, title: str, body: str, data: dict):
    """Fire-and-forget FCM multicast. Silently skips if not configured."""
    try:
        import firebase_admin
        from firebase_admin import credentials, messaging
        from .models import FcmToken

        tokens = list(FcmToken.objects.filter(user=user).values_list('token', flat=True))
        if not tokens:
            return

        if not firebase_admin._apps:
            key_path = getattr(settings, 'FIREBASE_SERVICE_ACCOUNT_JSON', None)
            if not key_path:
                logger.debug("FIREBASE_SERVICE_ACCOUNT_JSON not set — skipping push.")
                return
            import os as _os
            if not _os.path.isabs(key_path):
                key_path = _os.path.join(settings.BASE_DIR, key_path)
            cred = credentials.Certificate(key_path)
            firebase_admin.initialize_app(cred)

        str_data = {k: str(v) for k, v in data.items() if v is not None}
        message = messaging.MulticastMessage(
            notification=messaging.Notification(title=title, body=body),
            data=str_data,
            tokens=tokens,
        )
        resp = messaging.send_each_for_multicast(message)
        logger.debug("FCM sent: success=%s failure=%s", resp.success_count, resp.failure_count)

        # Clean up invalid tokens
        for i, r in enumerate(resp.responses):
            if not r.success and r.exception:
                code = getattr(r.exception, 'code', '')
                if code in ('registration-token-not-registered', 'invalid-registration-token'):
                    FcmToken.objects.filter(token=tokens[i]).delete()
    except Exception:
        logger.exception("FCM push failed (non-fatal)")
