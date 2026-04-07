from rest_framework import serializers

from wardrobe.enums import ClothingCategory
from wardrobe.models import DetectedItemCandidate, UploadBatch, UploadedPhoto, WardrobeItem

VALID_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp", "image/heic"}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def validate_image_file(file):
    content_type = getattr(file, "content_type", None)
    if content_type and content_type not in VALID_IMAGE_TYPES:
        raise serializers.ValidationError(
            f"Unsupported image type '{content_type}'. "
            "Allowed: jpeg, png, webp, heic."
        )
    return file


# ---------------------------------------------------------------------------
# Upload batch create
# ---------------------------------------------------------------------------

class UploadBatchCreateSerializer(serializers.Serializer):
    images = serializers.ListField(
        child=serializers.ImageField(allow_empty_file=False),
        min_length=1,
        max_length=3,
    )

    def validate_images(self, images):
        for img in images:
            validate_image_file(img)
        return images


# ---------------------------------------------------------------------------
# Read serializers
# ---------------------------------------------------------------------------

class DetectedItemCandidateSerializer(serializers.ModelSerializer):
    class Meta:
        model = DetectedItemCandidate
        fields = [
            "id",
            "photo",
            "is_selected",
            "category",
            "subcategory",
            "color",
            "style_tags",
            "confidence",
            "bounding_box",
            "cropped_image",
        ]
        read_only_fields = ["id", "photo", "confidence", "bounding_box", "cropped_image"]


class UploadedPhotoSerializer(serializers.ModelSerializer):
    candidates = DetectedItemCandidateSerializer(many=True, read_only=True)

    class Meta:
        model = UploadedPhoto
        fields = ["id", "image", "uploaded_at", "candidates"]


class UploadBatchDetailSerializer(serializers.ModelSerializer):
    photos = UploadedPhotoSerializer(many=True, read_only=True)

    class Meta:
        model = UploadBatch
        fields = ["id", "status", "created_at", "updated_at", "photos"]


# ---------------------------------------------------------------------------
# Candidate PATCH (review)
# ---------------------------------------------------------------------------

class CandidateUpdateEntrySerializer(serializers.Serializer):
    id = serializers.IntegerField()
    is_selected = serializers.BooleanField(required=False)
    category = serializers.ChoiceField(choices=ClothingCategory.choices, required=False)
    subcategory = serializers.CharField(max_length=100, required=False, allow_blank=True)
    color = serializers.CharField(max_length=100, required=False, allow_blank=True)
    style_tags = serializers.ListField(
        child=serializers.CharField(), required=False, default=list
    )


class CandidateBatchUpdateSerializer(serializers.Serializer):
    candidates = CandidateUpdateEntrySerializer(many=True)


# ---------------------------------------------------------------------------
# WardrobeItem
# ---------------------------------------------------------------------------

class WardrobeItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = WardrobeItem
        fields = [
            "id",
            "category",
            "subcategory",
            "color",
            "style_tags",
            "image",
            "name",
            "notes",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "image", "created_at", "updated_at"]
