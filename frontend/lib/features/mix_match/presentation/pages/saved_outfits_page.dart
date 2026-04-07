import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';

class SavedOutfitsPage extends StatelessWidget {
  const SavedOutfitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dynamic mock data ready for state management integration
    final List<Map<String, dynamic>> savedOutfits = [
      {
        "title": "Casual",
        "date": "Apr 25",
        "items": "Outer,Tops,Bottom,Bags",
      },
      {
        "title": "Concert Night",
        "date": "Mar 30",
        "items": "Outer,Tops,Bottom, +4",
      },
      {
        "title": "Coffee Date",
        "date": "Mar 20",
        "items": "Outer,Tops,Bottom, +3",
      },
      {
        "title": "Work Chic",
        "date": "Mar 10",
        "items": "Outer,Tops,Bottom, +3",
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Outfits',
          style: AppTextStyles.headline.copyWith(fontSize: 22),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.notifications_none, color: AppColors.blushPink, size: 28),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.78, // Adjust to fit content optimally
        ),
        itemCount: savedOutfits.length,
        itemBuilder: (context, index) {
          final outfit = savedOutfits[index];
          return _buildOutfitCard(outfit);
        },
      ),
    );
  }

  Widget _buildOutfitCard(Map<String, dynamic> outfit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Heart Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  outfit['title'],
                  style: AppTextStyles.productName.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.favorite, color: AppColors.blushPink, size: 24),
            ],
          ),
          const SizedBox(height: 2),
          
          // Date & Items Row
          Row(
            children: [
              Text(
                outfit['date'],
                style: AppTextStyles.small.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  outfit['items'],
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.secondaryText,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Image / Placeholder Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.roseMist.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.checkroom, color: AppColors.roseMist, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Footer Row: Preview Button & Action Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Preview Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warmCream,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Preview',
                  style: AppTextStyles.type.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                    fontSize: 11,
                  ),
                ),
              ),
              
              // Action Icons
              const Row(
                children: [
                  Icon(Icons.delete_outline, color: AppColors.blushPink, size: 20),
                  SizedBox(width: 6),
                  Icon(Icons.copy_outlined, color: AppColors.blushPink, size: 20),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
