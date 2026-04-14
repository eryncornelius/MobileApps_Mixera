from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    RegisterView, VerifyOTPView,
    ForgotPasswordView, ResetPasswordView, MeView, CustomLoginView, GoogleAuthView, FacebookAuthView,
    UpdateProfileView, ChangePasswordView, AddressListCreateView, AddressDetailView,
    NotificationSettingsView,
    UserNotificationListView, UserNotificationReadView, UserNotificationUnreadCountView,
    FcmTokenRegisterView,
)

urlpatterns = [
    path('login/', CustomLoginView.as_view(), name='token_obtain_pair'),
    path('login/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('google/', GoogleAuthView.as_view(), name='google_auth'),
    path('facebook/', FacebookAuthView.as_view(), name='facebook_auth'),
    path('register/', RegisterView.as_view(), name='auth_register'),
    path('verify-otp/', VerifyOTPView.as_view(), name='verify_otp'),
    path('forgot-password/', ForgotPasswordView.as_view(), name='forgot_password'),
    path('reset-password/', ResetPasswordView.as_view(), name='reset_password'),
    path('me/', MeView.as_view(), name='me'),
    path('profile/', UpdateProfileView.as_view(), name='update_profile'),
    path('change-password/', ChangePasswordView.as_view(), name='change_password'),
    path('addresses/', AddressListCreateView.as_view(), name='address_list_create'),
    path('addresses/<int:pk>/', AddressDetailView.as_view(), name='address_detail'),
    path('notification-settings/', NotificationSettingsView.as_view(), name='notification_settings'),
    path('notifications/', UserNotificationListView.as_view(), name='user_notifications'),
    path('notifications/read/', UserNotificationReadView.as_view(), name='user_notifications_read'),
    path('notifications/unread-count/', UserNotificationUnreadCountView.as_view(), name='user_notifications_unread_count'),
    path('fcm-token/', FcmTokenRegisterView.as_view(), name='fcm_token_register'),
]