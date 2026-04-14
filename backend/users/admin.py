from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, OTPVerification, NotificationSettings, UserNotification, FcmToken


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    model = User
    list_display = (
        'email',
        'auth_provider',
        'google_id',
        'facebook_id',
        'username',
        'is_seller',
        'is_staff',
        'is_superuser',
        'is_email_verified',
    )
    ordering = ('email',)

    fieldsets = UserAdmin.fieldsets + (
        ('Additional Info', {
            'fields': (
                'phone_number',
                'is_email_verified',
                'is_seller',
                'ai_tokens',
                'is_premium',
                'premium_until',
            )
        }),
    )

    add_fieldsets = UserAdmin.add_fieldsets + (
        (None, {
            'fields': (
                'email',
                'phone_number',
                'is_email_verified',
                'is_seller',
                'ai_tokens',
                'is_premium',
                'premium_until',
            )
        }),
    )


@admin.register(OTPVerification)
class OTPVerificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'code', 'created_at', 'is_used')
    list_filter = ('is_used', 'created_at')
    search_fields = ('user__email', 'code')
    
@admin.register(NotificationSettings)
class NotificationSettingsAdmin(admin.ModelAdmin):
    list_display = ('user', 'order_updates', 'promotions', 'security_alerts', 'daily_reminders')


@admin.register(UserNotification)
class UserNotificationAdmin(admin.ModelAdmin):
    list_display = ['user', 'notif_type', 'title', 'is_read', 'created_at']
    list_filter = ['notif_type', 'is_read']
    search_fields = ['user__email', 'title', 'body']
    readonly_fields = ['created_at']

@admin.register(FcmToken)
class FcmTokenAdmin(admin.ModelAdmin):
    list_display = ['user', 'platform', 'updated_at']
    search_fields = ['user__email', 'token']
