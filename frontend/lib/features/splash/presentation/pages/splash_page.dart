import 'package:flutter/material.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

// [1] Tambah TickerProviderStateMixin
class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  static const String _text = 'MIXÉRA';
  static const int _letterDelayMs = 500;

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;
  late final AnimationController _logoController; 
  late final Animation<double> _logoAnimation;    

  @override
  void initState() {
    super.initState();

    // [TAMBAH] Setup logo controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoAnimation = CurvedAnimation(parent: _logoController, curve: Curves.easeIn);

    _controllers = List.generate(
      _text.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _animations = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeIn))
        .toList();

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    _logoController.forward(); // [TAMBAH] logo & huruf M muncul bersamaan
    _controllers[0].forward();

    for (int i = 1; i < _text.length; i++) {
      await Future.delayed(const Duration(milliseconds: _letterDelayMs));
      if (!mounted) return;
      _controllers[i].forward();
    }

    await Future.delayed(const Duration(milliseconds: _letterDelayMs));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.authGate);
  }

  @override
  void dispose() {
    _logoController.dispose(); // [TAMBAH] dispose logo controller
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softWhite,
      body: Center(
        child: Column(                              // [UBAH] Row → Column
          mainAxisSize: MainAxisSize.min,
          children: [
            // [TAMBAH] Logo dengan FadeTransition
            FadeTransition(
              opacity: _logoAnimation,
              child: Image.asset(
                'assets/images/Logo_Mixera.png',          // sesuaikan path asset
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 24),            // [TAMBAH] jarak logo ke teks
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_text.length, (i) {
                return FadeTransition(
                  opacity: _animations[i],
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