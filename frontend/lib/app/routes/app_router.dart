import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/auth_gate_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/checkout/presentation/pages/card_3ds_page.dart';
import '../../features/checkout/presentation/pages/card_tokenize_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/checkout/presentation/pages/purchase_complete_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/navigation/presentation/pages/main_shell_page.dart';
import '../../features/profile/data/models/address_model.dart';
import '../../features/profile/presentation/pages/add_new_address_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/profile/presentation/pages/edit_address_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/saved_addresses_page.dart';
import '../../features/profile/presentation/pages/saved_try_on_photos_page.dart';
import '../../features/profile/presentation/pages/security_page.dart';
import '../../features/profile/presentation/pages/wishlist_page.dart';
import '../../features/mix_match/presentation/pages/saved_outfits_page.dart';
import '../../features/shop/presentation/pages/product_detail_page.dart';
import '../../features/shop/presentation/pages/search_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/wallet/presentation/pages/add_money_page.dart';
import '../../features/wallet/presentation/pages/snap_webview_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/wardrobe/presentation/pages/wardrobe_page.dart';
import '../../features/seller/presentation/pages/seller_shell_page.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static String get initialRoute => RouteNames.splash;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.authGate:
        return MaterialPageRoute(builder: (_) => const AuthGatePage());

      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

      case RouteNames.mainShell:
        return MaterialPageRoute(
          builder: (_) => const MainShellPage(),
          settings: settings,
        );

      case RouteNames.sellerShell:
        return MaterialPageRoute(
          builder: (_) => const SellerShellPage(),
          settings: settings,
        );

      case RouteNames.resetPassword:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ResetPasswordPage(email: email),
        );

      case RouteNames.otp:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => OtpVerificationPage(email: email),
        );

      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case RouteNames.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfilePage());

      case RouteNames.savedAddresses:
        return MaterialPageRoute(builder: (_) => const SavedAddressesPage());

      case RouteNames.addNewAddress:
        return MaterialPageRoute(builder: (_) => const AddNewAddressPage());

      case RouteNames.editAddress:
        final address = settings.arguments as AddressModel;
        return MaterialPageRoute(
          builder: (_) => EditAddressPage(address: address),
        );

      case RouteNames.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());

      case RouteNames.security:
        return MaterialPageRoute(builder: (_) => const SecurityPage());

      case RouteNames.notificationSettings:
        return MaterialPageRoute(
          builder: (_) => const NotificationsPage(),
        );

      case RouteNames.wallet:
        return MaterialPageRoute(builder: (_) => const WalletPage());

      case RouteNames.addMoney:
        return MaterialPageRoute(builder: (_) => const AddMoneyPage());

      case RouteNames.snapWebView:
        final args = settings.arguments as SnapWebViewArgs;
        return MaterialPageRoute(builder: (_) => SnapWebViewPage(args: args));

      case RouteNames.shopSearch:
        return MaterialPageRoute(builder: (_) => const SearchPage());

      case RouteNames.productDetail:
        final slug = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ProductDetailPage(slug: slug));

      case RouteNames.cart:
        return MaterialPageRoute(builder: (_) => const CartPage());

      case RouteNames.checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutPage());

      case RouteNames.purchaseComplete:
        return MaterialPageRoute(builder: (_) => const PurchaseCompletePage());

      // case RouteNames.cardTokenize:
      //   final args = settings.arguments as CardTokenizeArgs;
      //   return MaterialPageRoute(builder: (_) => CardTokenizePage(args: args));
      case RouteNames.cardTokenize:
        final args = settings.arguments as CardTokenizeArgs;
        return MaterialPageRoute<CardTokenResult?>(
          builder: (_) => CardTokenizePage(args: args),
          settings: settings,
        );

      // case RouteNames.card3DS:
      //   final args = settings.arguments as Card3DSArgs;
      //   return MaterialPageRoute(builder: (_) => Card3DSPage(args: args));
       
      case RouteNames.card3DS:
        final args = settings.arguments as Card3DSArgs;
        return MaterialPageRoute<Card3DSResult?>(
          builder: (_) => Card3DSPage(args: args),
          settings: settings,
        );
      case RouteNames.orders:
        return MaterialPageRoute(builder: (_) => const OrdersPage());

      case RouteNames.orderDetail:
        final orderId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => OrderDetailPage(orderId: orderId),
        );

      case RouteNames.wardrobe:
        return MaterialPageRoute(builder: (_) => const WardrobePage());

      case RouteNames.wishlist:
        return MaterialPageRoute(builder: (_) => const WishlistPage());

      case RouteNames.savedOutfits:
        return MaterialPageRoute(builder: (_) => const SavedOutfitsPage());

      case RouteNames.savedTryOnPhotos:
        return MaterialPageRoute(builder: (_) => const SavedTryOnPhotosPage());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
