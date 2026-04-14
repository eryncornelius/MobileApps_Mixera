from django.contrib import admin

from mixmatch.models import MixResult, MixSession


class MixResultInline(admin.StackedInline):
    model = MixResult
    extra = 0
    readonly_fields = [
        "style_label",
        "explanation",
        "tips",
        "score",
        "is_saved",
        "preview_image",
        "created_at",
    ]
    can_delete = False


@admin.register(MixSession)
class MixSessionAdmin(admin.ModelAdmin):
    list_display = ["id", "user", "status", "item_count", "created_at"]
    list_filter = ["status"]
    search_fields = ["user__email"]
    readonly_fields = ["created_at", "updated_at"]
    filter_horizontal = ["selected_items"]
    inlines = [MixResultInline]

    @admin.display(description="Items")
    def item_count(self, obj):
        return obj.selected_items.count()


@admin.register(MixResult)
class MixResultAdmin(admin.ModelAdmin):
    list_display = ["id", "session", "style_label", "score", "is_saved", "created_at"]
    list_filter = ["is_saved", "style_label"]
    search_fields = ["session__user__email"]
    readonly_fields = ["created_at", "preview_image"]
