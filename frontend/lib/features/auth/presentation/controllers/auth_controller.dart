import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../../../app/routes/route_names.dart';
import '../../../seller/presentation/controllers/seller_controller.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../../../core/biometric/biometric_lock_storage.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/services/fcm_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthController extends GetxController {
  final AuthRemoteDatasource _api = AuthRemoteDatasource();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Stores the init future so continueWithGoogle can await it.
  // google_sign_in v7 requires initialize() to complete before authenticate().
  Future<void>? _initFuture;

  Future<void> initGoogleSignIn() async {
    await _googleSignIn.initialize(
      serverClientId: dotenv.env['SERVER_CLIENT_ID'],
    );
  }

  Future<void> continueWithGoogle(BuildContext context) async {
    isLoading.value = true;
    try {
      await _initFuture; // ensure initialize() has completed
      final account = await _googleSignIn.authenticate();
      final auth = account.authentication;
      final idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google ID token tidak ditemukan');
      }

      final result = await _api.loginWithGoogle(idToken);
      final access = result['access'] as String?;
      final refresh = result['refresh'] as String?;

      if (access == null || refresh == null) {
        throw Exception('Token aplikasi tidak ditemukan dari server');
      }

      await TokenStorage.saveTokens(accessToken: access, refreshToken: refresh);
      FcmService.registerAfterLogin();
      debugPrint('ACCESS TOKEN: $access');
      debugPrint('REFRESH TOKEN: $refresh');
      debugPrint('USER Login');
      if (!context.mounted) return;
      _showSnackbar(context, 'Login Google berhasil!', true);

      final userMap = result['user'] is Map
          ? Map<String, dynamic>.from(result['user'] as Map)
          : null;
      if (!context.mounted) return;
      _navigateHome(context, userJson: userMap);
    } catch (e) {
      if (!context.mounted) return;
      _showSnackbar(context, e.toString().replaceAll('Exception: ', ''), false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> continueWithFacebook(BuildContext context) async {
  isLoading.value = true;

  try {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );


    if (result.status != LoginStatus.success) {
      throw Exception(result.message ?? 'Facebook login gagal');
    }

    final accessToken = result.accessToken?.tokenString;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Facebook access token tidak ditemukan');
    }

    final response = await _api.loginWithFacebook(accessToken);
    debugPrint('FB STEP 4: backend response = $response');

    final access = response['access'] as String?;
    final refresh = response['refresh'] as String?;

    if (access == null || refresh == null) {
      throw Exception('Token aplikasi tidak ditemukan dari server');
    }

    await TokenStorage.saveTokens(accessToken: access, refreshToken: refresh);
    FcmService.registerAfterLogin();

    final savedAccess = await TokenStorage.getAccessToken();
    debugPrint('FB STEP 5: saved access = $savedAccess');

    if (!context.mounted) return;

    final userMap = response['user'] is Map
        ? Map<String, dynamic>.from(response['user'] as Map)
        : null;
    _navigateHome(context, userJson: userMap);
  } catch (e, st) {
    debugPrint('FB ERROR: $e');
    debugPrint('FB STACK: $st');

    if (!context.mounted) return;
    _showSnackbar(context, e.toString().replaceAll('Exception: ', ''), false);
  } finally {
    isLoading.value = false;
  }
}
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();

  final forgotEmailController = TextEditingController();

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final otpControllers = List.generate(4, (_) => TextEditingController());
  final resetOtpControllers = List.generate(4, (_) => TextEditingController());

  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isResetPasswordHidden = true.obs;
  final isResetConfirmPasswordHidden = true.obs;
  final isLoading = false.obs;

  String get otpCode => otpControllers.map((c) => c.text.trim()).join();
  String get resetOtpCode => resetOtpControllers.map((c) => c.text.trim()).join();
  @override
  void onInit() {
    super.onInit();
    _initFuture = initGoogleSignIn();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void toggleResetPasswordVisibility() {
    isResetPasswordHidden.value = !isResetPasswordHidden.value;
  }

  void toggleResetConfirmPasswordVisibility() {
    isResetConfirmPasswordHidden.value = !isResetConfirmPasswordHidden.value;
  }

  void _navigateHome(BuildContext context, {Map<String, dynamic>? userJson}) {
    final isSeller = userJson != null && userJson['is_seller'] == true;
    // Drop any previous SellerController so a new session runs onInit/refreshAll
    // with the JWT just saved (avoids stale seller UI after Google/social login).
    if (Get.isRegistered<SellerController>()) {
      Get.delete<SellerController>(force: true);
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      isSeller ? RouteNames.sellerShell : RouteNames.mainShell,
      (route) => false,
    );
  }

  void _showSnackbar(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  void clearOtpFields() {
    for (final controller in otpControllers) {
      controller.clear();
    }
  }

  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar(context, 'Email and password cannot be empty', false);
      return;
    }

    if (!_isEmailValid(email)) {
      _showSnackbar(context, 'Format email tidak valid', false);
      return;
    }

    isLoading.value = true;
    try {
      final result = await _api.login(email, password);
      final access = result['access'] as String?;
      final refresh = result['refresh'] as String?;

      if (access == null || refresh == null) {
        throw Exception('Token tidak ditemukan dari server');
      }

      await TokenStorage.saveTokens(accessToken: access, refreshToken: refresh);
      FcmService.registerAfterLogin();

      if (!context.mounted) return;
      _showSnackbar(context, 'Login Berhasil!', true);

      final userMap = result['user'] is Map
          ? Map<String, dynamic>.from(result['user'] as Map)
          : null;
      if (!context.mounted) return;
      _navigateHome(context, userJson: userMap);
    } catch (e) {
      _showSnackbar(context, e.toString().replaceAll('Exception: ', ''), false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(BuildContext context) async {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      _showSnackbar(context, 'Harap isi semua kolom wajib!', false);
      return;
    }

    if (!_isEmailValid(email)) {
      _showSnackbar(context, 'Format email tidak valid', false);
      return;
    }

    isLoading.value = true;
    try {
      await _api.register(email, username, phone, password);
      if (!context.mounted) return;
      clearOtpFields();

      _showSnackbar(context, 'Kode OTP telah dikirim ke email Anda.', true);

      Navigator.pushNamed(context, RouteNames.otp, arguments: email);
    } catch (e) {
      _showSnackbar(context, e.toString().replaceAll('Exception: ', ''), false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(BuildContext context, String email) async {
    final code = otpCode;

    if (code.length != 4) {
      _showSnackbar(context, 'Masukkan 4 digit OTP', false);
      return;
    }

    isLoading.value = true;
    try {
      await _api.verifyOtp(email, code);
      if (!context.mounted) return;
      clearOtpFields();

      _showSnackbar(context, 'Akun aktif! Silakan Login.', true);

      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.login,
        (route) => false,
      );
    } catch (e) {
      _showSnackbar(context, e.toString().replaceAll('Exception: ', ''), false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendForgotPasswordCode(BuildContext context) async {
    final email = forgotEmailController.text.trim();

    if (email.isEmpty) {
      _showSnackbar(context, 'Email wajib diisi', false);
      return;
    }

    if (!_isEmailValid(email)) {
      _showSnackbar(context, 'Format email tidak valid', false);
      return;
    }

    isLoading.value = true;
    try {
      await _api.forgotPassword(email);
      if (!context.mounted) return;
      for (final c in resetOtpControllers) { c.clear(); }
      newPasswordController.clear();
      confirmPasswordController.clear();

      _showSnackbar(context, 'Kode reset berhasil dikirim', true);

      Navigator.pushNamed(context, RouteNames.resetPassword, arguments: email);
    } catch (e) {
      _showSnackbar(context, e.toString().replaceAll('Exception: ', ''), false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(
    BuildContext context, {
    required String email,
  }) async {
    final code = resetOtpCode;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (code.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackbar(context, 'Semua field wajib diisi', false);
      return;
    }

    if (code.length != 4) {
      _showSnackbar(context, 'OTP harus 4 digit', false);
      return;
    }

    isLoading.value = true;
    try {
      await _api.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      if (!context.mounted) return;
      for (final c in resetOtpControllers) { c.clear(); }
      newPasswordController.clear();
      confirmPasswordController.clear();
      forgotEmailController.clear();

      _showSnackbar(context, 'Password berhasil direset. Silakan login.', true);

      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.login,
        (route) => false,
      );
    } catch (e) {
      _showSnackbar(context, e.toString().replaceAll('Exception: ', ''), false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await TokenStorage.clearTokens();
      await BiometricLockStorage.setLockEnabled(false);
      if (Get.isRegistered<SellerController>()) {
        Get.delete<SellerController>(force: true);
      }
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();

      if (!context.mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.login,
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      _showSnackbar(context, 'Logout gagal', false);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    forgotEmailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final controller in resetOtpControllers) {
      controller.dispose();
    }

    super.onClose();
  }
}
