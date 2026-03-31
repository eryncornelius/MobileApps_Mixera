import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/profile_controller.dart';

/// Shared address form used by both AddNewAddressPage and EditAddressPage.
class AddressForm extends StatelessWidget {
  final ProfileController profileC;

  const AddressForm({super.key, required this.profileC});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label tabs
          Obx(() => _LabelTabs(
                selected: profileC.selectedAddressLabel.value,
                onSelect: (label) => profileC.selectedAddressLabel.value = label,
              )),
          const SizedBox(height: 20),
          _field('Full Name', profileC.recipientNameController, hint: 'Recipient name'),
          const SizedBox(height: 16),
          _field('Phone Number', profileC.addressPhoneController,
              hint: '+1 555 000-0000', type: TextInputType.phone),
          const SizedBox(height: 16),
          _field('Street Address', profileC.streetAddressController,
              hint: '123 Main St'),
          const SizedBox(height: 16),
          _field('City', profileC.cityController, hint: 'City'),
          const SizedBox(height: 16),
          _field('State', profileC.stateController, hint: 'State'),
          const SizedBox(height: 16),
          _field('Zip Code', profileC.postalCodeController,
              hint: '00000', type: TextInputType.number),
          const SizedBox(height: 20),
          // Set as Primary checkbox
          Obx(() => GestureDetector(
                onTap: () => profileC.isPrimaryAddress.value =
                    !profileC.isPrimaryAddress.value,
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: profileC.isPrimaryAddress.value
                              ? AppColors.primaryText
                              : AppColors.border,
                          width: 1.6,
                        ),
                        color: profileC.isPrimaryAddress.value
                            ? AppColors.primaryText
                            : Colors.transparent,
                      ),
                      child: profileC.isPrimaryAddress.value
                          ? const Icon(Icons.check_rounded,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text('Set as Primary Address',
                        style: AppTextStyles.description),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String hint = '', TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.description),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _LabelTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _LabelTabs({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.warmCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _Tab(label: 'Home', value: 'home', selected: selected, onSelect: onSelect),
          _Tab(label: 'Work', value: 'work', selected: selected, onSelect: onSelect),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelect;

  const _Tab({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isActive ? AppColors.blushPink : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: isActive ? Colors.white : AppColors.secondaryText,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
