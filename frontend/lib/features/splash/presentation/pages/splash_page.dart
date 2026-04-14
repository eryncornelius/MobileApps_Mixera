import 'package:flutter/material.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  /// Teks brand; huruf per huruf pakai `AppTextStyles.logo` (Google Fonts di theme, bukan TTF custom).
  static const String _text = 'MIXÉRA';
  static const int _letterDelayMs = 500;

  late final AnimationController _logoController;
  late final Animation<double> _logoAnimation;
  late final List<AnimationController> _letterControllers;
  late final List<Animation<double>> _letterAnimations;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoAnimation = CurvedAnimation(parent: _logoController, curve: Curves.easeIn);

    _letterControllers = List.generate(
      _text.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _letterAnimations = _letterControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeIn))
        .toList();

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    _logoController.forward();
    if (_letterControllers.isNotEmpty) {
      _letterControllers[0].forward();
    }

    for (int i = 1; i < _text.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: _letterDelayMs));
      if (!mounted) return;
      _letterControllers[i].forward();
    }

    await Future<void>.delayed(const Duration(milliseconds: _letterDelayMs));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.authGate);
  }

  @override
  void dispose() {
    _logoController.dispose();
    for (final c in _letterControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softWhite,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _logoAnimation,
              child: Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.checkroom_rounded,
                  size: 80,
                  color: AppColors.blushPink,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_text.length, (i) {
                return FadeTransition(
                  opacity: _letterAnimations[i],
                  child: Text(
                    _text[i],
                    style: AppTextStyles.logo.copyWith(
                      color: AppColors.blushPink,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
