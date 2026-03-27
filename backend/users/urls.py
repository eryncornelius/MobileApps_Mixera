from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    RegisterView, VerifyOTPView, 
    ForgotPasswordView, ResetPasswordView, MeView, CustomLoginView, GoogleAuthView, FacebookAuthView, UpdateProfileView
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
    path("profile/", UpdateProfileView.as_view(), name="update_profile"),
]