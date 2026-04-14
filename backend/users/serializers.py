import re
from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Address, FcmToken, NotificationSettings, UserNotification
User = get_user_model()


def validate_password_strength(value):
    if len(value) < 8:
        raise serializers.ValidationError("Password must be at least 8 characters.")
    if not re.search(r'\d', value):
        raise serializers.ValidationError("Password must include at least one number.")
    if not re.search(r'[!@#$%^&*(),.?":{}|<>]', value):
        raise serializers.ValidationError("Password must include at least one symbol (!@#$...).")
    if not re.search(r'[a-z]', value) or not re.search(r'[A-Z]', value):
        raise serializers.ValidationError("Password must include both uppercase and lowercase letters.")
    return value


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password_strength])

    class Meta:
        model = User
        fields = ('email', 'username', 'phone_number', 'password')

    def create(self, validated_data):
        # Gunakan create_user agar password otomatis di-hash
        return User.objects.create_user(**validated_data)
from django.contrib.auth import authenticate
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth import get_user_model

User = get_user_model()

class GoogleAuthSerializer(serializers.Serializer):
    id_token = serializers.CharField()
    
class FacebookAuthSerializer(serializers.Serializer):
    access_token = serializers.CharField()
    
class UserMeSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = (
            'id',
            'email',
            'pending_email',
            'username',
            'phone_number',
            'is_email_verified',
            'is_seller',
            'ai_tokens',
            'is_premium',
            'premium_until',
        )


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    username_field = User.EMAIL_FIELD

    def validate(self, attrs):
        data = super().validate(attrs)

        user = self.user

        if not user.is_email_verified:
            raise serializers.ValidationError({
                "detail": "Please verify your email first."
            })

        data["user"] = UserMeSerializer(user).data
        return data
    
    
class VerifyOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.CharField(max_length=4)

class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()

class ResetPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.CharField(max_length=4)
    new_password = serializers.CharField(write_only=True, validators=[validate_password_strength])
    confirm_password = serializers.CharField(write_only=True)

    def validate(self, data):
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError({"confirm_password": "Passwords do not match."})
        return data
    
    
# Section : Profile

class ProfileSerializer(serializers.ModelSerializer):
    seller_store_name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = (
            "id",
            "email",
            "pending_email",
            "username",
            "phone_number",
            "auth_provider",
            "is_email_verified",
            "is_seller",
            "seller_store_name",
            "is_premium",
            "premium_until",
        )

    def get_seller_store_name(self, obj):
        profile = getattr(obj, "seller_profile", None)
        return profile.store_name if profile else ""


class UpdateProfileSerializer(serializers.ModelSerializer):
    """Username & telepon; ubah email lewat alur OTP terpisah."""

    class Meta:
        model = User
        fields = (
            "username",
            "phone_number",
        )

    def validate_username(self, value):
        user = self.instance
        qs = User.objects.filter(username=value)
        if user:
            qs = qs.exclude(id=user.id)
        if qs.exists():
            raise serializers.ValidationError("Username already taken.")
        return value


class EmailChangeRequestSerializer(serializers.Serializer):
    new_email = serializers.EmailField()


class EmailChangeConfirmSerializer(serializers.Serializer):
    code = serializers.CharField(max_length=4, min_length=4)

class ChangePasswordSerializer(serializers.Serializer):
    current_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True, validators=[validate_password_strength])

    def validate(self, attrs):
        user = self.context["request"].user

        if not user.check_password(attrs["current_password"]):
            raise serializers.ValidationError({
                "current_password": ["Current password is incorrect."]
            })

        return attrs
    
# Addresses
class AddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = Address
        fields = (
            "id",
            "label",
            "recipient_name",
            "phone_number",
            "street_address",
            "city",
            "state",
            "postal_code",
            "is_primary",
            "created_at",
            "updated_at",
        )

    def create(self, validated_data):
        user = self.context["request"].user

        if not user.addresses.exists():
            validated_data["is_primary"] = True

        return Address.objects.create(user=user, **validated_data)


# Notification Settings
class NotificationSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationSettings
        fields = ("order_updates", "promotions", "security_alerts", "daily_reminders")


# User Notifications
class UserNotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserNotification
        fields = ("id", "notif_type", "title", "body", "is_read", "payload", "created_at")
        read_only_fields = ("id", "notif_type", "title", "body", "payload", "created_at")


class FcmTokenSerializer(serializers.Serializer):
    token = serializers.CharField()
    platform = serializers.ChoiceField(choices=FcmToken.PLATFORM_CHOICES, default='android')