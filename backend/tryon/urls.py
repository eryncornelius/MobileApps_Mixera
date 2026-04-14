from django.urls import path

from tryon.views import (
    PersonImageActivateView,
    PersonImageDeleteView,
    PersonImageListCreateView,
    TryOnRequestCreateView,
    TryOnRequestDetailView,
    TryOnResultDetailView,
    TryOnResultSaveView,
    TryOnSavedResultsListView,
)

urlpatterns = [
    # Person profile images
    path("person-images/", PersonImageListCreateView.as_view(), name="tryon-person-images"),
    path("person-images/<int:image_id>/activate/", PersonImageActivateView.as_view(), name="tryon-person-activate"),
    path("person-images/<int:image_id>/", PersonImageDeleteView.as_view(), name="tryon-person-delete"),

    # Try-on requests & results
    path("requests/", TryOnRequestCreateView.as_view(), name="tryon-request-create"),
    path("requests/<int:request_id>/", TryOnRequestDetailView.as_view(), name="tryon-request-detail"),
    path("results/saved/", TryOnSavedResultsListView.as_view(), name="tryon-results-saved"),
    path("results/<int:result_id>/save/", TryOnResultSaveView.as_view(), name="tryon-result-save"),
    path("results/<int:result_id>/", TryOnResultDetailView.as_view(), name="tryon-result-detail"),
]
