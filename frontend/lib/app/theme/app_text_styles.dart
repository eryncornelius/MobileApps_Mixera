import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // 🔥 LOGO / BRAND
  static final TextStyle logo = GoogleFonts.dmSerifDisplay(
    fontSize: 26,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
    letterSpacing: 1.2,
  );

  // 🧠 HEADLINE (24)
  static final TextStyle headline = GoogleFonts.dmSerifDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
  );

  // 📌 SECTION TITLE (18)
  static final TextStyle section = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  // 🛍️ PRODUCT NAME (16)
  static final TextStyle productName = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  // 📝 DESCRIPTION (14)
  static final TextStyle description = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
  );

  // 💰 PRICE / SMALL INFO (12)
  static final TextStyle small = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
  );

  // 🏷️ TYPE / TAG (12 but medium)
  static final TextStyle type = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  // 🔘 BUTTON
  static final TextStyle button = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
