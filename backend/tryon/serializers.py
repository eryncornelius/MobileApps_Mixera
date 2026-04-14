from rest_framework import serializers

from tryon.models import PersonProfileImage, TryOnRequest, TryOnResult, TryOnSourceType


# ---------------------------------------------------------------------------
# Person image
# ---------------------------------------------------------------------------

class PersonProfileImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = PersonProfileImage
        fields = ["id", "image", "label", "is_active", "is_archived", "uploaded_at"]
        read_only_fields = ["id", "is_active", "is_archived", "uploaded_at"]


class PersonProfileImageUploadSerializer(serializers.Serializer):
    image = serializers.ImageField(allow_empty_file=False)
    label = serializers.CharField(max_length=100, required=False, allow_blank=True, default="")
    set_active = serializers.BooleanField(required=False, default=False)


# ---------------------------------------------------------------------------
# Try-on request (create)
# ---------------------------------------------------------------------------

class TryOnRequestCreateSerializer(serializers.Serializer):
    person_image_id = serializers.IntegerField(min_value=1)
    source_type = serializers.ChoiceField(choices=TryOnSourceType.choices)
    # Conditionally required — validated in validate()
    mix_result_id = serializers.IntegerField(min_value=1, required=False, allow_null=True)
    shop_product_id = serializers.IntegerField(min_value=1, required=False, allow_null=True)

    def validate(self, data):
        source_type = data.get("source_type")

        if source_type == TryOnSourceType.MIX_RESULT:
            if not data.get("mix_result_id"):
                raise serializers.ValidationError(
                    {"mix_result_id": "This field is required when source_type is 'mix_result'."}
                )

        elif source_type == TryOnSourceType.SHOP_PRODUCT:
            if not data.get("shop_product_id"):
                raise serializers.ValidationError(
                    {"shop_product_id": "This field is required when source_type is 'shop_product'."}
                )

        return data


# ---------------------------------------------------------------------------
# Try-on request / result (read)
# ---------------------------------------------------------------------------

class TryOnResultSerializer(serializers.ModelSerializer):
    class Meta:
        model = TryOnResult
        fields = ["id", "result_image", "notes", "is_saved", "created_at"]
        read_only_fields = fields


class TryOnSavedEntrySerializer(serializers.ModelSerializer):
    """Compact row for GET /tryon/results/saved/."""

    request_id = serializers.IntegerField(source="request.id", read_only=True)
    source_type = serializers.CharField(source="request.source_type", read_only=True)

    class Meta:
        model = TryOnResult
        fields = [
            "id",
            "request_id",
            "source_type",
            "result_image",
            "is_saved",
            "notes",
            "created_at",
        ]
        read_only_fields = fields


class TryOnRequestDetailSerializer(serializers.ModelSerializer):
    result = TryOnResultSerializer(read_only=True)
    person_image = PersonProfileImageSerializer(read_only=True)

    class Meta:
        model = TryOnRequest
        fields = [
            "id",
            "status",
            "error_message",
            "source_type",
            "person_image",
            "mix_result",
            "shop_product",
            "result",
            "created_at",
            "updated_at",
        ]
        read_only_fields = fields
