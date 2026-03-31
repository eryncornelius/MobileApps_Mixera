import 'package:get/get.dart';

import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/datasources/wallet_remote_datasource.dart';
import '../../data/models/wallet_model.dart';
import '../../data/models/wallet_transaction_model.dart';

class WalletController extends GetxController {
  final WalletRemoteDatasource _walletRemote = WalletRemoteDatasource();
  final PaymentRemoteDatasource _paymentRemote = PaymentRemoteDatasource();

  final wallet = Rxn<WalletModel>();
  final transactions = <WalletTransactionModel>[].obs;

  final isLoadingWallet = false.obs;
  final isLoadingTransactions = false.obs;
  final isCreatingTransaction = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWallet();
    fetchTransactions();
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

  @override
  Future<void> refresh() async {
    await Future.wait([fetchWallet(), fetchTransactions()]);
  }

  /// Creates a Midtrans Snap transaction and returns the snap_token.
  /// Returns null on failure.
  Future<Map<String, dynamic>?> createTopUp(int amount) async {
    isCreatingTransaction.value = true;
    try {
      final result = await _paymentRemote.createSnapTransaction(
        amount: amount,
        purpose: 'wallet_topup',
      );
      return result;
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
      final result = await _paymentRemote.getTransactionStatus(orderId);
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
