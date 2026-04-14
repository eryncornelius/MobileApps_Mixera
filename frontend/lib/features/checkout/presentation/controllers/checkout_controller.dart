import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../../cart/data/datasources/cart_local_datasource.dart';
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
  final _cartQuoteDs = CartRemoteDatasource();

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

  /// Baris teks ringkas (catatan API, berat) setelah [fetchShippingQuotePreview].
  final shippingQuoteLines = <String>[].obs;
  final isLoadingShippingQuote = false.obs;

  /// Hasil tarif per kurir/layanan (urut dari termurah).
  final shippingQuotes = <Map<String, dynamic>>[].obs;

  /// null = pakai ongkir default server; selain itu = indeks ke [shippingQuotes].
  final selectedShippingQuoteIndex = Rxn<int>();

  /// Ongkir yang dikirim ke checkout (null → default server).
  final selectedDeliveryFee = Rxn<int>();
  static const int defaultDeliveryFee = 20000;
  int get checkoutDeliveryFeeDisplay => selectedDeliveryFee.value ?? defaultDeliveryFee;

  /// Tanpa spasi — .env seperti `KEY = value` sering menyisakan spasi di depan nilai.
  String get midtransClientKey =>
      (dotenv.env['MIDTRANS_CLIENT_KEY'] ?? '').trim();

  bool get midtransIsSandbox =>
      dotenv.env['MIDTRANS_IS_PRODUCTION']?.toLowerCase() != 'true';

  @override
  void onInit() {
    super.onInit();
    final profileC = Get.find<ProfileController>();
    // Pick immediately if already loaded, then keep watching for async load
    _pickDefaultAddress(profileC.addresses);
    ever(profileC.addresses, _pickDefaultAddress);
    ever(selectedAddressId, (_) {
      selectedDeliveryFee.value = null;
      shippingQuoteLines.clear();
      shippingQuotes.clear();
      selectedShippingQuoteIndex.value = null;
    });
    loadSavedCards(selectDefaultIfUnset: true);
    refreshWalletBalance();
  }

  void _pickDefaultAddress(List<AddressModel> addresses) {
    if (selectedAddressId.value != null) return;
    final pick = addresses.firstWhereOrNull((a) => a.isPrimary) ?? addresses.firstOrNull;
    if (pick != null) selectedAddressId.value = pick.id;
  }

  /// Refetch wallet from API (e.g. after user topped up elsewhere; [onInit] also calls this).
  Future<void> refreshWalletBalance() async {
    try {
      final wallet = await _walletDs.getWallet();
      walletBalance.value = wallet.balance;
    } catch (_) {
      // silent — balance display is informational only
    }
  }

  /// Ongkir ke alamat terpilih — isi [shippingQuotes] + pilihan default/indeks pertama.
  Future<void> fetchShippingQuotePreview() async {
    final addressId = selectedAddressId.value;
    if (addressId == null) {
      shippingQuoteLines.assignAll(['Pilih alamat pengiriman dulu.']);
      return;
    }
    isLoadingShippingQuote.value = true;
    shippingQuoteLines.clear();
    shippingQuotes.clear();
    selectedShippingQuoteIndex.value = null;
    selectedDeliveryFee.value = null;
    errorMessage = null;
    try {
      final m = await _cartQuoteDs.postShippingQuote(addressId: addressId);
      final note = m['note'] as String? ?? '';
      final raw = (m['quotes'] as List?) ?? [];
      final w = m['estimated_weight_grams'];
      final parsed = raw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((q) => (q['price'] as num?) != null)
          .toList();
      parsed.sort((a, b) {
        final pa = (a['price'] as num?)?.toInt() ?? 0;
        final pb = (b['price'] as num?)?.toInt() ?? 0;
        return pa.compareTo(pb);
      });
      shippingQuotes.assignAll(parsed);

      if (parsed.isNotEmpty) {
        selectedShippingQuoteIndex.value = 0;
        selectedDeliveryFee.value = (parsed[0]['price'] as num).toInt();
      }

      shippingQuoteLines.assignAll([
        'Berat estimasi: ${w ?? "?"} g',
        note,
        if (parsed.isEmpty)
          'Tidak ada tarif kurir — checkout memakai ongkir default.',
      ]);
    } catch (e) {
      selectedDeliveryFee.value = null;
      selectedShippingQuoteIndex.value = null;
      shippingQuotes.clear();
      shippingQuoteLines.assignAll([e.toString().replaceFirst('Exception: ', '')]);
    } finally {
      isLoadingShippingQuote.value = false;
    }
  }

  /// null = ongkir default server; [i] = tarif dari [shippingQuotes][i].
  void selectShippingQuote(int? index) {
    if (index == null) {
      selectedShippingQuoteIndex.value = null;
      selectedDeliveryFee.value = null;
      return;
    }
    if (index < 0 || index >= shippingQuotes.length) return;
    selectedShippingQuoteIndex.value = index;
    final p = (shippingQuotes[index]['price'] as num?)?.toInt();
    selectedDeliveryFee.value = p;
  }

  /// Refreshes saved cards from the API.
  ///
  /// When [selectDefaultIfUnset] is true (e.g. first open), picks the default
  /// card only if nothing is selected yet. Otherwise we never overwrite a
  /// deliberate `null` from "Use a new card" — the old behavior always
  /// re-selected the default after every refresh and broke new-card checkout.
  Future<void> loadSavedCards({bool selectDefaultIfUnset = false}) async {
    isLoadingSavedCards.value = true;
    try {
      savedCards.assignAll(await _cardDs.getSavedCards());
      final sel = selectedSavedCardId.value;
      if (sel != null && !savedCards.any((c) => c.id == sel)) {
        selectedSavedCardId.value = null;
      }
      if (selectDefaultIfUnset && selectedSavedCardId.value == null) {
        final defaultCard = savedCards.firstWhereOrNull((c) => c.isDefault);
        if (defaultCard != null) {
          selectedSavedCardId.value = defaultCard.id;
        }
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
          deliveryFee: selectedDeliveryFee.value,
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
          deliveryFee: selectedDeliveryFee.value,
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
    bool retryThreeDs = false,
  }) async {
    isChargingCard.value = true;
    errorMessage = null;
    try {
      final result = await _cardDs.chargeCard(
        orderId: orderId,
        cardToken: cardToken,
        savedCardId: savedCardId,
        saveCard: saveCard,
        retryThreeDs: retryThreeDs,
      );

      if (result.isFailed) {
        errorMessage = 'Card payment was declined. Please try a different card.';
        return null;
      }

      return result;
    } on CardChargeApiException catch (e) {
      if (e.shouldUseNewCard) {
        // Saved token is no longer usable. Reset selection so next attempt
        // naturally goes through new-card tokenize flow.
        selectedSavedCardId.value = null;
        errorMessage = 'Saved card is no longer valid. Please use a new card.';
        // Refresh list in case backend removed or invalidated the card record.
        loadSavedCards();
      } else {
        errorMessage = e.message;
      }
      return null;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isChargingCard.value = false;
    }
  }
}
