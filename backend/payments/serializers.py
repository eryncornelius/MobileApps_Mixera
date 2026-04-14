from rest_framework import serializers

from .models import SavedCard


class CreateSnapTransactionSerializer(serializers.Serializer):
    amount = serializers.IntegerField(min_value=1000)
    purpose = serializers.ChoiceField(choices=[("wallet_topup", "Wallet Top Up")])


class CardChargeSerializer(serializers.Serializer):
    CHARGE_PURPOSE_SHOP = "shop_order"
    CHARGE_PURPOSE_WALLET = "wallet_topup"

    charge_purpose = serializers.ChoiceField(
        choices=[
            (CHARGE_PURPOSE_SHOP, "Shop order"),
            (CHARGE_PURPOSE_WALLET, "Wallet top up"),
        ],
        default=CHARGE_PURPOSE_SHOP,
    )
    django_order_id = serializers.IntegerField(required=False, allow_null=True)
    amount = serializers.IntegerField(required=False, min_value=1000)
    card_token = serializers.CharField(required=False, allow_blank=True, default="")
    saved_card_id = serializers.IntegerField(required=False, allow_null=True, default=None)
    save_card = serializers.BooleanField(default=False)
    # Batalkan pending 3DS lalu charge ulang (URL redirect Midtrans sekali pakai).
    retry_three_ds = serializers.BooleanField(default=False)

    def validate(self, attrs):
        purpose = attrs.get("charge_purpose") or self.CHARGE_PURPOSE_SHOP
        if purpose == self.CHARGE_PURPOSE_SHOP:
            if attrs.get("django_order_id") is None:
                raise serializers.ValidationError(
                    {"django_order_id": "Required for shop order payment."}
                )
        else:
            if attrs.get("amount") is None:
                raise serializers.ValidationError(
                    {"amount": "Required for wallet top-up."}
                )
        if not attrs.get("card_token") and not attrs.get("saved_card_id"):
            raise serializers.ValidationError(
                "Either card_token or saved_card_id must be provided."
            )
        return attrs


class SavedCardSerializer(serializers.ModelSerializer):
    class Meta:
        model = SavedCard
        fields = [
            "id",
            "card_brand",
            "masked_card",
            "expiry_month",
            "expiry_year",
            "is_default",
            "created_at",
        ]
        read_only_fields = [
            "id",
            "card_brand",
            "masked_card",
            "expiry_month",
            "expiry_year",
            "is_default",
            "created_at",
        ]


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
