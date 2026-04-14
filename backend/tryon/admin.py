from django.contrib import admin

from tryon.models import PersonProfileImage, TryOnRequest, TryOnResult


class TryOnResultInline(admin.StackedInline):
    model = TryOnResult
    extra = 0
    fields = ["result_image", "notes", "is_saved", "created_at"]
    readonly_fields = ["result_image", "notes", "created_at"]
    can_delete = False


@admin.register(PersonProfileImage)
class PersonProfileImageAdmin(admin.ModelAdmin):
    list_display = ["id", "user", "label", "is_active", "is_archived", "uploaded_at"]
    list_filter = ["is_active", "is_archived"]
    search_fields = ["user__email", "label"]
    readonly_fields = ["uploaded_at"]


@admin.register(TryOnRequest)
class TryOnRequestAdmin(admin.ModelAdmin):
    list_display = ["id", "user", "source_type", "status", "person_image", "mix_result", "shop_product", "created_at"]
    list_filter = ["status"]
    search_fields = ["user__email"]
    readonly_fields = ["created_at", "updated_at"]
    inlines = [TryOnResultInline]


@admin.register(TryOnResult)
class TryOnResultAdmin(admin.ModelAdmin):
    list_display = ["id", "request", "has_image", "is_saved", "created_at"]
    list_filter = ["is_saved"]
    readonly_fields = ["created_at"]
    search_fields = ["request__user__email"]

    @admin.display(boolean=True, description="Has Image")
    def has_image(self, obj):
        return bool(obj.result_image)
