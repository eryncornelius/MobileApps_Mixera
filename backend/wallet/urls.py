from django.urls import path

from .views import WalletTransactionListView, WalletView

urlpatterns = [
    path('', WalletView.as_view(), name='wallet'),
    path('transactions/', WalletTransactionListView.as_view(), name='wallet_transactions'),
]
