import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/auth_gate_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/shop/presentation/pages/search_page.dart';
import '../../features/shop/presentation/pages/shop_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
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
      case RouteNames.editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfilePage(),
          settings: settings,
        );

      case RouteNames.search:
        return MaterialPageRoute(builder: (_) => const SearchPage());

      case RouteNames.shop:
        return MaterialPageRoute(builder: (_) => const ShopPage());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
