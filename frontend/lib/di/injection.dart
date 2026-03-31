import 'package:get/get.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/cart/presentation/controllers/cart_controller.dart';
import '../features/checkout/presentation/controllers/checkout_controller.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';
import '../features/shop/presentation/controllers/shop_controller.dart';
import '../features/wallet/presentation/controllers/wallet_controller.dart';

Future<void> initDependencies() async {
  Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  Get.lazyPut<WalletController>(() => WalletController(), fenix: true);
  Get.lazyPut<ShopController>(() => ShopController(), fenix: true);
  Get.lazyPut<CartController>(() => CartController(), fenix: true);
  Get.lazyPut<CheckoutController>(() => CheckoutController(), fenix: true);
}
