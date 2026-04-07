import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import 'confirm_items_page.dart';

class PickFromWardrobePage extends StatefulWidget {
  const PickFromWardrobePage({super.key});

  @override
  State<PickFromWardrobePage> createState() => _PickFromWardrobePageState();
}

class _PickFromWardrobePageState extends State<PickFromWardrobePage> {
  int _selectedTabIndex = 0;
  
  final List<String> _tabs = ['Tops', 'Outer', 'Bottom', 'Dress', 'Accessories'];

  // Mock items map for dynamic data readiness
  final List<Map<String, dynamic>> _mockItems = [
    {"icon": Icons.layers, "color": AppColors.roseMist, "selected": false},
    {"icon": Icons.airline_seat_legroom_extra, "color": AppColors.accent, "selected": false},
    {"icon": Icons.snowshoeing, "color": AppColors.blushPink.withOpacity(0.5), "selected": false},
    {"icon": Icons.layers, "color": AppColors.roseMist, "selected": false},
    {"icon": Icons.airline_seat_legroom_extra, "color": AppColors.accent, "selected": false},
    {"icon": Icons.snowshoeing, "color": AppColors.blushPink.withOpacity(0.5), "selected": false},
    {"icon": Icons.layers, "color": AppColors.roseMist, "selected": false},
    {"icon": Icons.airline_seat_legroom_extra, "color": AppColors.accent, "selected": false},
    {"icon": Icons.snowshoeing, "color": AppColors.blushPink.withOpacity(0.5), "selected": false},
  ];

  void _toggleSelection(int index) {
    setState(() {
      _mockItems[index]['selected'] = !(_mockItems[index]['selected'] as bool);
    });
  }

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
        title: Text(
          'Pick From Wardrobe',
          style: AppTextStyles.headline.copyWith(fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Tabs section
              Container(
                height: 45,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.blushPink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(22.5),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedTabIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.blushPink.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _tabs[index],
                          style: AppTextStyles.productName.copyWith(
                            color: isSelected ? AppColors.primaryText : AppColors.secondaryText,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              
              // Filter Button aligned to right
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_alt_outlined, color: AppColors.secondaryText, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Filter',
                          style: AppTextStyles.productName.copyWith(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Grid View
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: _mockItems.length,
                  itemBuilder: (context, index) {
                    final item = _mockItems[index];
                    final isSelected = item['selected'] as bool;
                    return GestureDetector(
                      onTap: () => _toggleSelection(index),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.softWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.blushPink : AppColors.border, 
                            width: isSelected ? 2 : 1.5
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.warmCream, // Placeholder flatlay bg
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(item['icon'], color: item['color'], size: 30),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected ? Icons.check : Icons.add, 
                                  color: AppColors.blushPink, 
                                  size: 16
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isSelected ? 'Added' : 'Add',
                                  style: AppTextStyles.productName.copyWith(
                                    color: AppColors.blushPink, // Pink font for Add button like design
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          // Bottom Sticky Area
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.roseMist.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 50,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.softWhite,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.button.copyWith(color: AppColors.primaryText),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Collect dynamically selected items then jump
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ConfirmItemsPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blushPink,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: Text(
                            'Add to outfit',
                            style: AppTextStyles.button,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
