import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';

class WardrobeDetailPage extends StatelessWidget {
  final String categoryName;
  final int count;

  const WardrobeDetailPage({
    super.key,
    this.categoryName = "tops",
    this.count = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream, // match bg
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'You own ',
                        style: AppTextStyles.headline.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: '$count ',
                            style: const TextStyle(color: AppColors.secondaryText),
                          ),
                          TextSpan(text: categoryName.toLowerCase()),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.softWhite,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                        border: Border.all(color: AppColors.border),
                      ),
                      child:  Row(
                        children: [
                          Icon(Icons.filter_alt_outlined, color: AppColors.secondaryText, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Filter',
                            style: AppTextStyles.productName.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 120),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72, 
                    ),
                    itemCount: count,
                    itemBuilder: (context, index) {
                      return _buildItemCard(
                        title: _getMockTitle(index),
                        isFavorite: index == 1 || index == 3 || index == 5, 
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Floating Bottom Area containing the ADD button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.warmCream.withOpacity(0.0),
                    AppColors.warmCream.withOpacity(0.9),
                    AppColors.warmCream,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(
                    'Something isnt Here?',
                    style: AppTextStyles.description.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blushPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.blushPink.withOpacity(0.4),
                      ),
                      child:  Text(
                        '+ Add Clothes',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                ],
              ),
            )
          )
        ],
      ),
    );
  }

  String _getMockTitle(int index) {
    List<String> titles = [
      "White Tank Top", 
      "Pink Camisole", 
      "White Tee", 
      "Stripped Tee", 
      "Pink Blouse", 
      "Cream Puff Sleeve Top", 
      "Blue Button Shirt", 
      "Warm Beige Knit"
    ];
    if (index < titles.length) return titles[index];
    return "Item ${index + 1}";
  }

  Widget _buildItemCard({required String title, required bool isFavorite}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.productName.copyWith(
                        fontSize: 14,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 24,
                      height: 2,
                      color: AppColors.blushPink,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.blushPink : Colors.grey.shade400,
                  size: 22,
                ),
              )
            ],
          ),
          const Spacer(),
          Center(
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: AppColors.warmCream, 
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.checkroom, color: AppColors.roseMist, size: 40),
            ),
          ),
          const Spacer(),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_outlined, size: 16, color: AppColors.blushPink),
                  SizedBox(width: 4),
                  Text('Edit', style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: AppColors.blushPink),
                  SizedBox(width: 8),
                  Icon(Icons.copy_outlined, size: 18, color: AppColors.blushPink),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
