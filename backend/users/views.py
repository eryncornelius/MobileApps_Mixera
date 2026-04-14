import requests
from rest_framework import status, generics
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from django.contrib.auth import get_user_model
from django.db import transaction as db_transaction
from rest_framework.permissions import IsAuthenticated
from .models import OTPVerification, Address, NotificationSettings, FcmToken, UserNotification
from django.conf import settings    
from google.auth.transport import requests as google_requests
from google.auth import exceptions as google_auth_exceptions
from google.oauth2 import id_token
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView
from .utils import send_otp_email
from .serializers import (
    RegisterSerializer, VerifyOTPSerializer,
    ForgotPasswordSerializer, ResetPasswordSerializer, CustomTokenObtainPairSerializer, UserMeSerializer, GoogleAuthSerializer,
    FacebookAuthSerializer, ProfileSerializer, UpdateProfileSerializer, ChangePasswordSerializer, AddressSerializer,
    NotificationSettingsSerializer, UserNotificationSerializer, FcmTokenSerializer,
)
from django.shortcuts import get_object_or_404

User = get_user_model()
class CustomLoginView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer
class GoogleAuthView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = GoogleAuthSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        google_id_token = serializer.validated_data['id_token']

        try:
            payload = id_token.verify_oauth2_token(
                google_id_token,
                google_requests.Request(),
                settings.GOOGLE_OAUTH_CLIENT_ID,
            )
        except (ValueError, google_auth_exceptions.TransportError):
            return Response(
                {"detail": "Invalid Google token."},
                status=status.HTTP_400_BAD_REQUEST
            )

        email = payload.get('email')
        google_sub = payload.get('sub')
        email_verified = payload.get('email_verified', False)
        name = payload.get('name') or (email.split('@')[0] if email else 'user')

        if not email:
            return Response(
                {"detail": "Google account email not provided."},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = User.objects.filter(email=email).first()

        if user is None:
            base_username = name.replace(' ', '')[:150] or email.split('@')[0]
            username = base_username
            counter = 1

            while User.objects.filter(username=username).exists():
                username = f"{base_username}{counter}"
                counter += 1

            user = User.objects.create(
                email=email,
                username=username,
                auth_provider='google',
                google_id=google_sub,
                is_email_verified=email_verified or True,
            )
            user.set_unusable_password()
            user.save()
        else:
            if user.auth_provider == 'email':
                return Response(
                    {"detail": "Email ini sudah terdaftar menggunakan email dan password. Silahkan login dengan email dan password Anda."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            if not user.google_id:
                user.google_id = google_sub
            user.auth_provider = 'google'
            user.is_email_verified = True
            user.save()

        refresh = RefreshToken.for_user(user)

        return Response(
            {
                "access": str(refresh.access_token),
                "refresh": str(refresh),
                "user": UserMeSerializer(user).data,
            },
            status=status.HTTP_200_OK
        )
        
class FacebookAuthView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = FacebookAuthSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user_access_token = serializer.validated_data["access_token"]
        app_access_token = f"{settings.FACEBOOK_APP_ID}|{settings.FACEBOOK_APP_SECRET}"

        # 1) Validate token with Meta
        debug_response = requests.get(
            "https://graph.facebook.com/debug_token",
            params={
                "input_token": user_access_token,
                "access_token": app_access_token,
            },
            timeout=10,
        )

        if debug_response.status_code != 200:
            return Response(
                {"detail": "Failed to validate Facebook token."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        debug_data = debug_response.json().get("data", {})

        if not debug_data.get("is_valid"):
            return Response(
                {"detail": "Invalid Facebook token."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        facebook_user_id = debug_data.get("user_id")
        app_id = str(debug_data.get("app_id", ""))

        if app_id != str(settings.FACEBOOK_APP_ID):
            return Response(
                {"detail": "Facebook token does not belong to this app."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # 2) Fetch user profile
        me_response = requests.get(
            "https://graph.facebook.com/me",
            params={
                "fields": "id,name,email",
                "access_token": user_access_token,
            },
            timeout=10,
        )

        if me_response.status_code != 200:
            return Response(
                {"detail": "Failed to fetch Facebook user profile."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        profile = me_response.json()
        email = profile.get("email")
        name = profile.get("name") or "Facebook User"
        facebook_id = profile.get("id") or facebook_user_id

        if not facebook_id:
            return Response(
                {"detail": "Facebook user ID not found."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # email may be missing if not granted / unavailable
        user = None
        if facebook_id:
            user = User.objects.filter(facebook_id=facebook_id).first()
        if email:
            user = User.objects.filter(email=email).first()

        if user is None:
            base_username = (name or "facebookuser").replace(" ", "")[:150] or "facebookuser"
            username = base_username
            counter = 1

            while User.objects.filter(username=username).exists():
                username = f"{base_username}{counter}"
                counter += 1
            fallback_email = email if email else f"{facebook_id}@facebook.local"
            
            user = User.objects.create(
                email=email if email else fallback_email,
                username=username,
                auth_provider="facebook",
                facebook_id=facebook_id,
                is_email_verified=True,
            )
            user.set_unusable_password()
            user.save()
        else:
            if user.auth_provider == 'email':
                return Response(
                    {"detail": "Email ini sudah terdaftar menggunakan email dan password. Silahkan login dengan email dan password Anda."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if not user.facebook_id:
                user.facebook_id = facebook_id
            user.auth_provider = "facebook"
            user.is_email_verified = True
            user.save()

        refresh = RefreshToken.for_user(user)

        return Response(
            {
                "access": str(refresh.access_token),
                "refresh": str(refresh),
                "user": UserMeSerializer(user).data,
            },
            status=status.HTTP_200_OK,
        )


class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = RegisterSerializer

    def perform_create(self, serializer):
        user = serializer.save()
        # Generate OTP dan kirim email setelah user berhasil dibuat
        otp = OTPVerification.generate_otp(user)
        send_otp_email(user.email, otp.code)

class VerifyOTPView(APIView):
    permission_classes = (AllowAny,)

    def post(self, request):
        serializer = VerifyOTPSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        email = serializer.validated_data['email']
        code = serializer.validated_data['code']

        user = User.objects.filter(email=email).first()
        if not user:
            return Response({"detail": "User not found."}, status=status.HTTP_404_NOT_FOUND)

        otp = OTPVerification.objects.filter(user=user, code=code).last()

        if not otp or not otp.is_still_valid():
            return Response({"detail": "Invalid or expired OTP."}, status=status.HTTP_400_BAD_REQUEST)

        # Tandai OTP sudah dipakai & verifikasi email user
        otp.is_used = True
        otp.save()
        
        user.is_email_verified = True
        user.save()

        return Response({"detail": "Email verified successfully."}, status=status.HTTP_200_OK)

class ForgotPasswordView(APIView):
    permission_classes = (AllowAny,)

    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        email = serializer.validated_data['email']
        user = User.objects.filter(email=email).first()

        if user:
            otp = OTPVerification.generate_otp(user)
            send_otp_email(user.email, otp.code)

        return Response({"detail": "If the email exists, an OTP has been sent."}, status=status.HTTP_200_OK)

class ResetPasswordView(APIView):
    permission_classes = (AllowAny,)

    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        email = serializer.validated_data['email']
        code = serializer.validated_data['code']
        new_password = serializer.validated_data['new_password']

        user = User.objects.filter(email=email).first()
        if not user:
            return Response({"detail": "User not found."}, status=status.HTTP_404_NOT_FOUND)

        otp = OTPVerification.objects.filter(user=user, code=code).last()

        if not otp or not otp.is_still_valid():
            return Response({"detail": "Invalid or expired OTP."}, status=status.HTTP_400_BAD_REQUEST)

        # Tandai OTP sudah dipakai & update password
        otp.is_used = True
        otp.save()

        user.set_password(new_password) # Hash password baru
        user.save()

        return Response({"detail": "Password has been reset successfully."}, status=status.HTTP_200_OK)
    
    
# Section: Profile





class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = ProfileSerializer(request.user)
        return Response(serializer.data)


class UpdateProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def put(self, request):
        serializer = UpdateProfileSerializer(
            request.user,
            data=request.data,
            partial=False,
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        response_serializer = ProfileSerializer(request.user)
        return Response(response_serializer.data, status=status.HTTP_200_OK)
    
class ChangePasswordView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = ChangePasswordSerializer(
            data=request.data,
            context={"request": request},
        )
        serializer.is_valid(raise_exception=True)

        user = request.user
        user.set_password(serializer.validated_data["new_password"])
        user.save()

        return Response(
            {"detail": "Password changed successfully."},
            status=status.HTTP_200_OK,
        )
        
# Address
class AddressListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        addresses = request.user.addresses.all()
        serializer = AddressSerializer(addresses, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = AddressSerializer(
            data=request.data,
            context={"request": request},
        )
        serializer.is_valid(raise_exception=True)
        address = serializer.save()

        response_serializer = AddressSerializer(address)
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)

class AddressDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def put(self, request, pk):
        address = get_object_or_404(Address, pk=pk, user=request.user)
        serializer = AddressSerializer(
            address,
            data=request.data,
            partial=False,
            context={"request": request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        response_serializer = AddressSerializer(address)
        return Response(response_serializer.data)

    def delete(self, request, pk):
        address = get_object_or_404(Address, pk=pk, user=request.user)
        was_primary = address.is_primary
        address.delete()

        if was_primary:
            next_address = request.user.addresses.order_by("-updated_at").first()
            if next_address:
                next_address.is_primary = True
                next_address.save()

        return Response({"detail": "Address deleted successfully."}, status=status.HTTP_200_OK)


# Notification Settings
class NotificationSettingsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        settings_obj, _ = NotificationSettings.objects.get_or_create(user=request.user)
        serializer = NotificationSettingsSerializer(settings_obj)
        return Response(serializer.data)

    def put(self, request):
        settings_obj, _ = NotificationSettings.objects.get_or_create(user=request.user)
        serializer = NotificationSettingsSerializer(settings_obj, data=request.data, partial=False)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


# User Notifications
class UserNotificationListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qs = UserNotification.objects.filter(user=request.user)[:50]
        return Response(UserNotificationSerializer(qs, many=True).data)


class UserNotificationReadView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.data.get('all'):
            UserNotification.objects.filter(user=request.user, is_read=False).update(is_read=True)
        else:
            notif_id = request.data.get('id')
            if notif_id:
                UserNotification.objects.filter(pk=notif_id, user=request.user).update(is_read=True)
        return Response({'ok': True})


class UserNotificationUnreadCountView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        count = UserNotification.objects.filter(user=request.user, is_read=False).count()
        return Response({'count': count})


# FCM Token
class FcmTokenRegisterView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        ser = FcmTokenSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        token = ser.validated_data['token']
        platform = ser.validated_data['platform']
        user = request.user
        # Satu token aktif per user per platform (hindari banyak baris setelah flutter run / refresh token).
        with db_transaction.atomic():
            FcmToken.objects.filter(user=user, platform=platform).exclude(token=token).delete()
            FcmToken.objects.update_or_create(
                token=token,
                defaults={'user': user, 'platform': platform},
            )
        return Response({'ok': True})