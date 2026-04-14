from rest_framework import serializers

from mixmatch.models import MixResult, MixSession
from wardrobe.serializers import WardrobeItemSerializer


# ---------------------------------------------------------------------------
# Session create / select
# ---------------------------------------------------------------------------

class MixSessionCreateSerializer(serializers.Serializer):
    """No body required — session is created empty."""
    pass


class SelectItemsSerializer(serializers.Serializer):
    item_ids = serializers.ListField(
        child=serializers.IntegerField(min_value=1),
        min_length=1,
        max_length=5,
    )


# ---------------------------------------------------------------------------
# Read serializers
# ---------------------------------------------------------------------------

class MixResultSerializer(serializers.ModelSerializer):
    class Meta:
        model = MixResult
        fields = [
            "id",
            "style_label",
            "explanation",
            "tips",
            "score",
            "is_saved",
            "preview_image",
            "created_at",
        ]
        read_only_fields = fields


class MixSessionDetailSerializer(serializers.ModelSerializer):
    selected_items = WardrobeItemSerializer(many=True, read_only=True)
    result = MixResultSerializer(read_only=True)

    class Meta:
        model = MixSession
        fields = ["id", "status", "selected_items", "result", "created_at", "updated_at"]
        read_only_fields = fields


class MixResultDetailSerializer(serializers.ModelSerializer):
    """Full result detail — `selected_items` is the single winning outfit; `all_selected_items` is the full picker pool."""

    selected_items = serializers.SerializerMethodField()
    all_selected_items = serializers.SerializerMethodField()

    class Meta:
        model = MixResult
        fields = [
            "id",
            "style_label",
            "explanation",
            "tips",
            "score",
            "is_saved",
            "preview_image",
            "created_at",
            "selected_items",
            "all_selected_items",
        ]
        read_only_fields = fields

    def get_selected_items(self, obj):
        from mixmatch.services.result_service import resolve_best_outfit_candidate

        pool = list(obj.session.selected_items.all())
        items = resolve_best_outfit_candidate(pool)
        return WardrobeItemSerializer(
            items, many=True, context=self.context
        ).data

    def get_all_selected_items(self, obj):
        items = obj.session.selected_items.all()
        return WardrobeItemSerializer(
            items, many=True, context=self.context
        ).data
