import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import 'pick_from_wardrobe_page.dart';

class MixMatchPage extends StatelessWidget {
  const MixMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dynamic mock data for clothing recommendations
    final List<Map<String, dynamic>> recommendations = [
      {"icon": Icons.layers, "color": AppColors.roseMist},
      {"icon": Icons.airline_seat_legroom_extra, "color": AppColors.accent},
      {"icon": Icons.snowshoeing, "color": AppColors.blushPink.withOpacity(0.5)},
    ];

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20, top: 10),
            child: Icon(Icons.notifications_none, color: AppColors.blushPink, size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // Brand Title
            Center(
              child: Text(
                'MIXÉRA',
                style: AppTextStyles.logo.copyWith(
                  color: AppColors.blushPink,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Main Title
            Center(
              child: Text(
                'Mix & Match',
                style: AppTextStyles.headline.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Subtitle
            Center(
              child: Text(
                'Let AI mix your clothes into a stylish outfit',
                textAlign: TextAlign.center,
                style: AppTextStyles.description,
              ),
            ),
            const SizedBox(height: 32),
            
            // Section Title 1
            Text(
              'Clothing Recommendations',
              style: AppTextStyles.section,
            ),
            const SizedBox(height: 16),
            
            // Dynamic Horizontal List
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final item = recommendations[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.warmCream, // Placeholder bg
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(item['icon'], color: item['color'], size: 40),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add, color: AppColors.blushPink, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              'Add',
                              style: AppTextStyles.productName.copyWith(
                                color: AppColors.primaryText,
                                fontSize: 14,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Pick From Wardrobe Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PickFromWardrobePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blushPink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: const Text(
                  'Pick From Wardrobe',
                  style: TextStyle(
                    color: AppColors.softWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Section Title 2
            Text(
              'Your Outfit Recommendation',
              style: AppTextStyles.section,
            ),
            const SizedBox(height: 16),
            
            // Recommendation Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chic and neutral look\nfor a day out',
                          style: AppTextStyles.productName.copyWith(
                            color: AppColors.secondaryText,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 100), // spacing before buttons
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blushPink,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Save Outfit',
                              style: TextStyle(color: AppColors.softWhite, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.border.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            child: const Text(
                              'Try Another',
                              style: TextStyle(color: AppColors.blushPink, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: AppColors.warmCream, // Placeholder flatlay bg
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(Icons.checkroom, color: AppColors.roseMist, size: 80),
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
