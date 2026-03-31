from rest_framework import serializers

from .models import SavedCard


class CreateSnapTransactionSerializer(serializers.Serializer):
    amount = serializers.IntegerField(min_value=1000)
    purpose = serializers.ChoiceField(choices=[("wallet_topup", "Wallet Top Up")])


class CardChargeSerializer(serializers.Serializer):
    django_order_id = serializers.IntegerField()
    card_token = serializers.CharField(required=False, allow_blank=True, default="")
    saved_card_id = serializers.IntegerField(required=False, allow_null=True, default=None)
    save_card = serializers.BooleanField(default=False)

    def validate(self, attrs):
        if not attrs.get("card_token") and not attrs.get("saved_card_id"):
            raise serializers.ValidationError(
                "Either card_token or saved_card_id must be provided."
            )
        return attrs


class SavedCardSerializer(serializers.ModelSerializer):
    class Meta:
        model = SavedCard
        fields = ["id", "card_brand", "masked_card", "is_default", "created_at"]
        read_only_fields = ["id", "card_brand", "masked_card", "is_default", "created_at"]


class PaymentTransactionSerializer(serializers.Serializer):
    order_id = serializers.CharField()
    snap_token = serializers.CharField(allow_null=True)
    redirect_url = serializers.URLField(allow_null=True)
    transaction_status = serializers.CharField()
    payment_type = serializers.CharField(allow_null=True)
    fraud_status = serializers.CharField(allow_null=True)
    gross_amount = serializers.IntegerField()
    purpose = serializers.CharField()
    payment_method_type = serializers.CharField(allow_null=True)
    linked_order_id = serializers.IntegerField(allow_null=True)
