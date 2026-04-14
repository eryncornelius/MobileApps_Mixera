import 'package:get/get.dart';

import '../../../checkout/data/datasources/card_payment_remote_datasource.dart';
import '../../../checkout/data/models/card_charge_result_model.dart';
import '../../../checkout/data/models/saved_card_model.dart';
import '../../data/datasources/wallet_remote_datasource.dart';
import '../../data/models/wallet_model.dart';
import '../../data/models/wallet_transaction_model.dart';

class WalletController extends GetxController {
  final WalletRemoteDatasource _walletRemote = WalletRemoteDatasource();
  final CardPaymentRemoteDatasource _cardPaymentRemote = CardPaymentRemoteDatasource();

  final wallet = Rxn<WalletModel>();
  final transactions = <WalletTransactionModel>[].obs;
  final savedCards = <SavedCardModel>[].obs;

  final isLoadingWallet = false.obs;
  final isLoadingTransactions = false.obs;
  final isLoadingCards = false.obs;
  final isCreatingTransaction = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWallet();
    fetchTransactions();
    fetchSavedCards();
  }

  Future<void> fetchWallet() async {
    isLoadingWallet.value = true;
    try {
      wallet.value = await _walletRemote.getWallet();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoadingWallet.value = false;
    }
  }

  Future<void> fetchTransactions() async {
    isLoadingTransactions.value = true;
    try {
      transactions.assignAll(await _walletRemote.getTransactions());
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  Future<void> fetchSavedCards() async {
    isLoadingCards.value = true;
    try {
      savedCards.assignAll(await _cardPaymentRemote.getSavedCards());
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoadingCards.value = false;
    }
  }

  Future<void> setDefaultCard(int cardId) async {
    try {
      await _cardPaymentRemote.setDefaultCard(cardId);
      await fetchSavedCards();
      Get.snackbar('Payment method', 'Default card updated.');
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> refresh() async {
    await Future.wait([fetchWallet(), fetchTransactions(), fetchSavedCards()]);
  }

  /// Core API: isi wallet dengan kartu (baru atau tersimpan). Tangani 3DS di UI.
  Future<CardChargeResultModel?> chargeWalletWithCard({
    required int amount,
    String cardToken = '',
    int? savedCardId,
    bool saveCard = false,
    bool retryThreeDs = false,
  }) async {
    isCreatingTransaction.value = true;
    try {
      final result = await _cardPaymentRemote.chargeWalletTopUp(
        amount: amount,
        cardToken: cardToken,
        savedCardId: savedCardId,
        saveCard: saveCard,
        retryThreeDs: retryThreeDs,
      );
      if (result.isFailed) {
        Get.snackbar('Pembayaran', 'Kartu ditolak. Coba kartu lain.');
        return null;
      }
      return result;
    } on CardChargeApiException catch (e) {
      if (e.shouldUseNewCard) {
        Get.snackbar('Kartu tersimpan', e.message);
      } else {
        Get.snackbar('Pembayaran', e.message);
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return null;
    } finally {
      isCreatingTransaction.value = false;
    }
  }

  /// Polls status and refreshes wallet if settled.
  Future<String> pollStatus(String orderId) async {
    try {
      final result = await _cardPaymentRemote.getTransactionStatus(orderId);
      final txStatus = result['transaction_status'] as String? ?? 'pending';
      if (txStatus == 'settlement' || txStatus == 'capture') {
        await refresh();
      }
      return txStatus;
    } catch (_) {
      return 'pending';
    }
  }
}
