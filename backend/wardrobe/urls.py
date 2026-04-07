from django.urls import path

from wardrobe.views import (
    UploadBatchConfirmView,
    UploadBatchCandidatesUpdateView,
    UploadBatchDetailView,
    UploadBatchListCreateView,
    WardrobeCategorySummaryView,
    WardrobeItemListView,
)

urlpatterns = [
    # Batch lifecycle
    path("upload-batches/", UploadBatchListCreateView.as_view(), name="wardrobe-upload-batches"),
    path("upload-batches/<int:batch_id>/", UploadBatchDetailView.as_view(), name="wardrobe-batch-detail"),
    path("upload-batches/<int:batch_id>/candidates/", UploadBatchCandidatesUpdateView.as_view(), name="wardrobe-batch-candidates"),
    path("upload-batches/<int:batch_id>/confirm/", UploadBatchConfirmView.as_view(), name="wardrobe-batch-confirm"),

    # Final wardrobe items
    path("items/", WardrobeItemListView.as_view(), name="wardrobe-items"),
    path("categories/summary/", WardrobeCategorySummaryView.as_view(), name="wardrobe-categories-summary"),
]
