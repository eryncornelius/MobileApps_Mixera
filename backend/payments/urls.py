from django.urls import path

from .views import (
    CardChargeView,
    CreateSnapTransactionView,
    MidtransNotificationView,
    PaymentMethodsView,
    PaymentStatusView,
    SavedCardDetailView,
    SavedCardListView,
)

urlpatterns = [
    # Snap — wallet top-up (QRIS, VA, dll.)
    path("create-snap-transaction/", CreateSnapTransactionView.as_view(), name="create_snap_transaction"),
    # Core API card charge — shop checkout & wallet top-up (kartu / kartu tersimpan)
    path("card/charge/", CardChargeView.as_view(), name="card_charge"),
    # Midtrans webhook
    path("notification/", MidtransNotificationView.as_view(), name="midtrans_notification"),
    # Transaction status polling
    path("status/<str:order_id>/", PaymentStatusView.as_view(), name="payment_status"),
    # Available payment methods list
    path("methods/", PaymentMethodsView.as_view(), name="payment_methods"),
    # Saved cards
    path("cards/", SavedCardListView.as_view(), name="saved_cards"),
    path("cards/<int:pk>/default/", SavedCardDetailView.as_view(), name="saved_card_default"),
    path("cards/<int:pk>/", SavedCardDetailView.as_view(), name="saved_card_detail"),
]
