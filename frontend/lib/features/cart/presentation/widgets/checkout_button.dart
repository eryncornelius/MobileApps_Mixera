import 'package:flutter/material.dart';

import '../../../../../app/theme/app_text_styles.dart';

class CheckoutButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const CheckoutButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text('Proceed to Checkout', style: AppTextStyles.button),
      ),
    );
  }
}
