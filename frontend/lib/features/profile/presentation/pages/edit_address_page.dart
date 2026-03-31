import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/address_model.dart';
import '../controllers/profile_controller.dart';
import '_address_form.dart';

class EditAddressPage extends StatefulWidget {
  final AddressModel address;

  const EditAddressPage({super.key, required this.address});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  @override
  void initState() {
    super.initState();
    Get.find<ProfileController>().fillAddressForm(widget.address);
  }

  @override
  Widget build(BuildContext context) {
    final profileC = Get.find<ProfileController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildHeader(context),
              const SizedBox(height: 28),
              AddressForm(profileC: profileC),
              const SizedBox(height: 28),
              Obx(() => ElevatedButton(
                    onPressed: profileC.isSavingAddress.value
                        ? null
                        : () async {
                            final success =
                                await profileC.updateAddress(widget.address.id);
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                    child: profileC.isSavingAddress.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text('Save Address'),
                  )),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.chevron_left_rounded,
                  size: 28, color: AppColors.primaryText),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'MIXÉRA',
                  style: AppTextStyles.logo
                      .copyWith(color: AppColors.blushPink, letterSpacing: 2),
                ),
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
        const SizedBox(height: 16),
        Text('Edit Address', style: AppTextStyles.headline),
      ],
    );
  }
}
