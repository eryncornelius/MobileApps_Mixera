import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import 'wardrobe_detail_page.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  final List<Map<String, dynamic>> categories = const [
    {"title": "Outer", "count": 3, "icon": Icons.layers},
    {"title": "Top", "count": 10, "icon": Icons.dry_cleaning},
    {"title": "Bags", "count": 6, "icon": Icons.shopping_bag_outlined},
    {"title": "Bottom", "count": 8, "icon": Icons.airline_seat_legroom_extra},
    {"title": "Accessories", "count": 9, "icon": Icons.watch_outlined},
    {"title": "Shoes", "count": 9, "icon": Icons.snowshoeing},
    {"title": "Dresses", "count": 5, "icon": Icons.accessibility_new_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream, 
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.notifications_none, color: AppColors.blushPink, size: 28),
                    ],
                  ),
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
                      'Add Clothes',
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
                      'Upload and organize new\nitems for your wardrobe',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.description.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // Top Upload Button
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.blushPink,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blushPink.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: Text(
                        'Upload Photos', 
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Grid
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: categories.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryCard(
                        context, 
                        category['title'] as String, 
                        category['count'] as int, 
                        category['icon'] as IconData,
                      );
                    },
                  ),
                  const SizedBox(height: 120), // Bottom padding for fixed buttons
                ],
              ),
            ),
            
            // Bottom Buttons Bar
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.warmCream.withOpacity(0.95), // Match background with minor opacity
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(color: AppColors.border.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: AppColors.softWhite,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.button.copyWith(
                                color: AppColors.primaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded( //i think this is better when user filled upload photos, then this button will show up, if not hidden the upload photos button
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: AppColors.blushPink,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            'Add to Wardrobe',
                            style: AppTextStyles.button,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, int count, IconData fallbackIcon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WardrobeDetailPage(categoryName: title, count: count),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: AppTextStyles.section.copyWith(
                        fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "$count",
                  style: AppTextStyles.description.copyWith(
                      fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: 24,
              height: 2,
              color: AppColors.blushPink,
            ),
            const Spacer(),
            Center(
              child: Icon(
                fallbackIcon,
                size: 60,
                color: AppColors.warmCream.withOpacity(0.8), // subtle large icon
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
