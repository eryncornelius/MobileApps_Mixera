import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';

class TryOnResultPage extends StatelessWidget {
  const TryOnResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.notifications_none, color: AppColors.blushPink, size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Brand Title
            Text(
              'MIXÉRA',
              style: AppTextStyles.logo.copyWith(
                color: AppColors.blushPink,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              'Final Try-On Result',
              style: AppTextStyles.headline.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Image Placeholder Container 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                width: double.infinity,
                height: 420,
                decoration: BoxDecoration(
                  color: AppColors.roseMist.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.person, color: AppColors.roseMist, size: 120),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border, color: AppColors.primaryText),
                      label: Text(
                        'Add to Favorites',
                        style: AppTextStyles.button.copyWith(color: AppColors.primaryText),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.softWhite,
                        side: BorderSide(color: AppColors.border, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.send, color: AppColors.softWhite, size: 18),
                      label: Text(
                        'Share',
                        style: AppTextStyles.button,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blushPink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Return to root to simulate finishing
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blushPink.withOpacity(0.8), // subtle bottom pink button
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Done',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
