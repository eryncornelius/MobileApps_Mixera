import 'package:flutter/material.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/storage/token_storage.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final hasToken = await TokenStorage.hasToken();

    if (!mounted) return;

    if (hasToken) {
      Navigator.pushReplacementNamed(context, RouteNames.mainShell);
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
