import requests
from rest_framework import status, generics
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from django.contrib.auth import get_user_model
from rest_framework.permissions import IsAuthenticated
from .models import OTPVerification
from django.conf import settings    
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView
from .utils import send_otp_email
from .serializers import (
    RegisterSerializer, VerifyOTPSerializer, 
    ForgotPasswordSerializer, ResetPasswordSerializer, CustomTokenObtainPairSerializer, UserMeSerializer, GoogleAuthSerializer,
    FacebookAuthSerializer
)

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
        except ValueError:
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
        
class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserMeSerializer(request.user)
        return Response(serializer.data)
    

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