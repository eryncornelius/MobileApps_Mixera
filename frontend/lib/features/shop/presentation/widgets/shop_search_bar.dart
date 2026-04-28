import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Pill radius used for shop search (keep in sync across placeholder + field).
const double kShopSearchBarRadius = 24;

/// Tappable fake search row (Shop home) — same silhouette as [ShopSearchTextField].
class ShopSearchBarPlaceholder extends StatelessWidget {
  const ShopSearchBarPlaceholder({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kShopSearchBarRadius),
        child: Ink(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.softWhite,
            borderRadius: BorderRadius.circular(kShopSearchBarRadius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.blushPink, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search...',
                  style: AppTextStyles.description.copyWith(color: AppColors.secondaryText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single-outline search field. Neutralises app-wide [InputDecorationTheme] so focus
/// does not stack an inner 18px border on top of a custom pill.
class ShopSearchTextField extends StatelessWidget {
  const ShopSearchTextField({
    super.key,
    required this.controller,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.clearVisible = false,
    this.onClear,
  });

  final TextEditingController controller;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool clearVisible;
  final VoidCallback? onClear;

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(kShopSearchBarRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final neutralizedInputTheme = Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );

    return Theme(
      data: neutralizedInputTheme,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.description.copyWith(color: AppColors.primaryText),
        cursorColor: AppColors.blushPink,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.softWhite,
          hintText: 'Search...',
          hintStyle: AppTextStyles.description.copyWith(color: AppColors.secondaryText),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.blushPink, size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
          suffixIcon: clearVisible
              ? IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.secondaryText),
                  onPressed: onClear,
                  splashRadius: 20,
                )
              : null,
          contentPadding: const EdgeInsets.fromLTRB(0, 12, 4, 12),
          isDense: true,
          border: _border(AppColors.border),
          enabledBorder: _border(AppColors.border),
          focusedBorder: _border(AppColors.blushPink, width: 1.5),
          disabledBorder: _border(AppColors.border),
          errorBorder: _border(AppColors.error),
          focusedErrorBorder: _border(AppColors.error, width: 1.5),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
