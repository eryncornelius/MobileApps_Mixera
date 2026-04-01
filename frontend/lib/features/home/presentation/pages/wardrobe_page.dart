import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  int _selectedIndex = 1;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EFEF),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// 🔔 Notification Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.notifications_none, color: Colors.pink),
                ],
              ),

              const SizedBox(height: 10),

              /// 🏷 Title
              const Center(
                child: Column(
                  children: [
                    Text(
                      "MIXÉRA",
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Wardrobe",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Keep track of what you own",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ➕ Add Clothes Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8A1A8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    "+ Add Clothes",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ❤️ Saved Outfit Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.grey.withValues(alpha: 0.2),
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.pink),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Saved Outfits",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "You have 4 Outfits",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🧥 Grid Categories
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
                children: [
                  _buildCategory("Outer", 3, "assets/outer.png"),
                  _buildCategory("Top", 10, "assets/top.png"),
                  _buildCategory("Bags", 6, "assets/bag.png"),
                  _buildCategory("Bottom", 8, "assets/bottom.png"),
                  _buildCategory("Accessories", 9, "assets/accessories.png"),
                  _buildCategory("Shoes", 9, "assets/shoes.png"),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 📦 Category Card
  Widget _buildCategory(String title, int count, String imagePath) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.grey.withValues(alpha: 0.15),
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title + Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                "$count",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 4),

          /// underline pink
          Container(
            width: 30,
            height: 2,
            color: Colors.pinkAccent,
          ),

          const Spacer(),

          /// Image
          Center(

          ),
        ],
      ),
    );
  }
}

// ── Navigation Item ─────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({           
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.blushPink : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: isSelected ? AppColors.blushPink : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Navigation ────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.softWhite,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isSelected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.checkroom_outlined,
                label: 'Wardrobe',
                isSelected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              // Centre Mix FAB
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.blushPink,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blushPink.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mix',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.blushPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.shopping_bag_outlined,
                label: 'Shop',
                isSelected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isSelected: selectedIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}