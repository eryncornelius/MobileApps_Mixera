import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import 'try_on_result_page.dart';
import 'mix_match_page.dart';

class OutfitResultPage extends StatelessWidget {
  const OutfitResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream, // Light blush ambient bg
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
              'Mix Outfit Result',
              style: AppTextStyles.headline.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Image and Overlay Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Mock Image Container
                  Container(
                    width: double.infinity,
                    height: 380,
                    margin: const EdgeInsets.only(bottom: 45), // space for overlapping card
                    decoration: BoxDecoration(
                      color: AppColors.roseMist.withOpacity(0.3), // placeholder bg
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.checkroom, color: AppColors.roseMist, size: 100),
                    ),
                  ),
                  
                  // Status Overlay Card
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.softWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Your outfit has been created!',
                            style: AppTextStyles.headline.copyWith(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Chic and Neutral look for a day out!',
                            style: AppTextStyles.description,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TryOnResultPage()),
                        );
                      },
                      icon: const Icon(Icons.person, color: AppColors.softWhite),
                      label: Text(
                        'Try on with a person!',
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
                        // Normally this would clear state and pop until first MixMatchPage
                        Navigator.popUntil(context, (route) => route.isFirst);
                        // Assuming push replacement if standalone test, but pop is cleaner
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blushPink.withOpacity(0.8), // Slightly subdued pink
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Mix again',
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
