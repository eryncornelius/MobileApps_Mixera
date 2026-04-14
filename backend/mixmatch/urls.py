from django.urls import path

from mixmatch.views import (
    MixResultDetailView,
    MixResultSaveView,
    MixSavedResultsListView,
    MixSessionCreateView,
    MixSessionDetailView,
    MixSessionGenerateView,
    MixSessionSelectItemsView,
)

urlpatterns = [
    # Session lifecycle
    path("sessions/", MixSessionCreateView.as_view(), name="mixmatch-session-create"),
    path("sessions/<int:session_id>/", MixSessionDetailView.as_view(), name="mixmatch-session-detail"),
    path("sessions/<int:session_id>/select-items/", MixSessionSelectItemsView.as_view(), name="mixmatch-session-select"),
    path("sessions/<int:session_id>/generate/", MixSessionGenerateView.as_view(), name="mixmatch-session-generate"),

    # Results (literal "saved" before <int:> pattern)
    path("results/saved/", MixSavedResultsListView.as_view(), name="mixmatch-results-saved"),
    path("results/<int:result_id>/", MixResultDetailView.as_view(), name="mixmatch-result-detail"),
    path("results/<int:result_id>/save/", MixResultSaveView.as_view(), name="mixmatch-result-save"),
]
