import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../profile/data/models/address_model.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../wallet/data/datasources/wallet_remote_datasource.dart';
import '../../data/datasources/card_payment_remote_datasource.dart';
import '../../data/datasources/checkout_remote_datasource.dart';
import '../../data/models/card_charge_result_model.dart';
import '../../data/models/checkout_request_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/models/saved_card_model.dart';

final _paymentMethods = [
  const PaymentMethodModel(
    id: 'wallet',
    label: 'Wallet',
    description: 'Pay using your Mixéra wallet balance',
  ),
  const PaymentMethodModel(
    id: 'card',
    label: 'Credit / Debit Card',
    description: 'Pay with a card via Midtrans',
  ),
];

class CheckoutController extends GetxController {
  final _ds = CheckoutRemoteDatasource();
  final _cardDs = CardPaymentRemoteDatasource();

  final selectedAddressId = Rxn<int>();
  final selectedPaymentMethod = 'wallet'.obs;
  final isPlacingOrder = false.obs;
  final isChargingCard = false.obs;
  final lastOrder = Rxn<OrderModel>();
  String? errorMessage;

  final paymentMethods = _paymentMethods;

  // Wallet balance
  final walletBalance = Rxn<int>();
  final _walletDs = WalletRemoteDatasource();

  // Saved cards
  final savedCards = <SavedCardModel>[].obs;
  final isLoadingSavedCards = false.obs;
  final selectedSavedCardId = Rxn<int>();

  String get midtransClientKey => dotenv.env['MIDTRANS_CLIENT_KEY'] ?? '';

  @override
  void onInit() {
    super.onInit();
    final profileC = Get.find<ProfileController>();
    // Pick immediately if already loaded, then keep watching for async load
    _pickDefaultAddress(profileC.addresses);
    ever(profileC.addresses, _pickDefaultAddress);
    loadSavedCards();
    _fetchWalletBalance();
  }

  void _pickDefaultAddress(List<AddressModel> addresses) {
    if (selectedAddressId.value != null) return;
    final pick = addresses.firstWhereOrNull((a) => a.isPrimary) ?? addresses.firstOrNull;
    if (pick != null) selectedAddressId.value = pick.id;
  }

  Future<void> _fetchWalletBalance() async {
    try {
      final wallet = await _walletDs.getWallet();
      walletBalance.value = wallet.balance;
    } catch (_) {
      // silent — balance display is informational only
    }
  }

  Future<void> loadSavedCards() async {
    isLoadingSavedCards.value = true;
    try {
      savedCards.assignAll(await _cardDs.getSavedCards());
      final defaultCard = savedCards.firstWhereOrNull((c) => c.isDefault);
      if (defaultCard != null) {
        selectedSavedCardId.value = defaultCard.id;
      }
    } catch (_) {
      // Silent — user can still pay with a new card
    } finally {
      isLoadingSavedCards.value = false;
    }
  }

  /// Wallet checkout — creates order and deducts balance atomically.
  Future<bool> placeOrder() async {
    final addressId = selectedAddressId.value;
    if (addressId == null) {
      errorMessage = 'Please select a shipping address.';
      return false;
    }

    isPlacingOrder.value = true;
    errorMessage = null;
    try {
      final order = await _ds.checkout(
        CheckoutRequestModel(
          addressId: addressId,
          paymentMethod: 'wallet',
        ),
      );
      lastOrder.value = order;
      Get.find<CartController>().fetchCart();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isPlacingOrder.value = false;
    }
  }

  /// Card checkout — creates an unpaid order and returns it for card charge.
  /// If a card order was already created this session (lastOrder is unpaid card),
  /// reuses it instead of creating a duplicate.
  Future<OrderModel?> createCardOrder() async {
    final existing = lastOrder.value;
    if (existing != null &&
        existing.paymentMethod == 'card' &&
        existing.paymentStatus == 'unpaid') {
      return existing;
    }

    final addressId = selectedAddressId.value;
    if (addressId == null) {
      errorMessage = 'Please select a shipping address.';
      return null;
    }

    isPlacingOrder.value = true;
    errorMessage = null;
    try {
      final order = await _ds.checkout(
        CheckoutRequestModel(
          addressId: addressId,
          paymentMethod: 'card',
        ),
      );
      lastOrder.value = order;
      return order;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isPlacingOrder.value = false;
    }
  }

  /// Clears the pending card order so a fresh one is created next time.
  void clearCardOrder() => lastOrder.value = null;

  /// Charges the card and returns the raw result so the caller can handle
  /// 3DS redirect, immediate capture, or failure itself.
  /// Returns null on network/server error (errorMessage is set).
  Future<CardChargeResultModel?> chargeCardRaw({
    required int orderId,
    String cardToken = '',
    int? savedCardId,
    bool saveCard = false,
  }) async {
    isChargingCard.value = true;
    errorMessage = null;
    try {
      final result = await _cardDs.chargeCard(
        orderId: orderId,
        cardToken: cardToken,
        savedCardId: savedCardId,
        saveCard: saveCard,
      );

      if (result.isFailed) {
        errorMessage = 'Card payment was declined. Please try a different card.';
        return null;
      }

      return result;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isChargingCard.value = false;
    }
  }
}
