from django.contrib import admin

from wardrobe.models import DetectedItemCandidate, UploadBatch, UploadedPhoto, WardrobeItem


class UploadedPhotoInline(admin.TabularInline):
    model = UploadedPhoto
    extra = 0
    readonly_fields = ["uploaded_at"]


class DetectedItemCandidateInline(admin.TabularInline):
    model = DetectedItemCandidate
    extra = 0
    readonly_fields = ["confidence", "bounding_box", "ai_raw_response", "created_at"]


@admin.register(UploadBatch)
class UploadBatchAdmin(admin.ModelAdmin):
    list_display = ["id", "user", "status", "created_at"]
    list_filter = ["status"]
    search_fields = ["user__email"]
    readonly_fields = ["created_at", "updated_at"]
    inlines = [UploadedPhotoInline]


@admin.register(UploadedPhoto)
class UploadedPhotoAdmin(admin.ModelAdmin):
    list_display = ["id", "batch", "uploaded_at"]
    readonly_fields = ["uploaded_at"]
    inlines = [DetectedItemCandidateInline]


@admin.register(DetectedItemCandidate)
class DetectedItemCandidateAdmin(admin.ModelAdmin):
    list_display = ["id", "photo", "category", "subcategory", "is_selected", "confidence"]
    list_filter = ["category", "is_selected"]
    readonly_fields = ["confidence", "bounding_box", "ai_raw_response", "created_at"]


@admin.register(WardrobeItem)
class WardrobeItemAdmin(admin.ModelAdmin):
    list_display = ["id", "user", "category", "subcategory", "color", "created_at"]
    list_filter = ["category"]
    search_fields = ["user__email", "name"]
    readonly_fields = ["created_at", "updated_at"]
