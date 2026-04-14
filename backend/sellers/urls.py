from django.urls import path

from .views import (
    SellerChannelListingView,
    SellerDashboardView,
    SellerFinanceEarningsExportView,
    SellerFinanceEarningsView,
    SellerFinancePayoutsView,
    SellerMeView,
    SellerNotificationsReadView,
    SellerNotificationsView,
    SellerOrderDetailView,
    SellerOrderListView,
    SellerProductDetailView,
    SellerProductImageUploadView,
    SellerProductListCreateView,
    SellerShippingQuoteView,
)

urlpatterns = [
    path("me/", SellerMeView.as_view(), name="seller_me"),
    path("dashboard/", SellerDashboardView.as_view(), name="seller_dashboard"),
    path("products/", SellerProductListCreateView.as_view(), name="seller_products"),
    path(
        "products/upload-image/",
        SellerProductImageUploadView.as_view(),
        name="seller_product_upload_image",
    ),
    path("products/<int:pk>/", SellerProductDetailView.as_view(), name="seller_product_detail"),
    path("orders/", SellerOrderListView.as_view(), name="seller_orders"),
    path("orders/<int:pk>/", SellerOrderDetailView.as_view(), name="seller_order_detail"),
    path("finance/earnings/", SellerFinanceEarningsView.as_view(), name="seller_finance_earnings"),
    path(
        "finance/earnings/export/",
        SellerFinanceEarningsExportView.as_view(),
        name="seller_finance_earnings_export",
    ),
    path("finance/payouts/", SellerFinancePayoutsView.as_view(), name="seller_finance_payouts"),
    path("notifications/", SellerNotificationsView.as_view(), name="seller_notifications"),
    path("notifications/read/", SellerNotificationsReadView.as_view(), name="seller_notifications_read"),
    path("shipping/quote/", SellerShippingQuoteView.as_view(), name="seller_shipping_quote"),
    path("channels/", SellerChannelListingView.as_view(), name="seller_channels"),
]
