import 'package:get/get.dart';

import '../features/cart/presentation/controllers/cart_controller.dart';
import '../features/checkout/presentation/controllers/checkout_controller.dart';
import '../features/mix_match/presentation/controllers/mix_match_controller.dart';
import '../features/notifications/presentation/controllers/notifications_controller.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';
import '../features/seller/presentation/controllers/seller_controller.dart';
import '../features/shop/presentation/controllers/shop_controller.dart';
import '../features/tryon/presentation/controllers/tryon_controller.dart';
import '../features/wallet/presentation/controllers/wallet_controller.dart';
import '../features/wardrobe/presentation/controllers/wardrobe_controller.dart';

/// Hapus instance GetX yang menyimpan data per-user agar login berikutnya
/// membuat controller baru + `onInit` (profil, keranjang, seller, dll.).
///
/// Jangan sertakan [AuthController] — dipakai layar login.
void resetUserSessionControllers() {
  void del<T>() {
    if (Get.isRegistered<T>()) {
      Get.delete<T>(force: true);
    }
  }

  del<ProfileController>();
  del<CartController>();
  del<CheckoutController>();
  del<WalletController>();
  del<ShopController>();
  del<WardrobeController>();
  del<TryOnController>();
  del<MixMatchController>();
  del<SellerController>();
  del<NotificationsController>();
}
