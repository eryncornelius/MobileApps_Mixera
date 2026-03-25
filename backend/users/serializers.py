from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)

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
            'username',
            'phone_number',
            'is_email_verified',
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
    new_password = serializers.CharField(write_only=True, min_length=6)
    confirm_password = serializers.CharField(write_only=True, min_length=6)

    def validate(self, data):
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError({"confirm_password": "Passwords do not match."})
        return data