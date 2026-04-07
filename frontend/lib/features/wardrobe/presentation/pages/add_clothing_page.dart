import 'package:flutter/material.dart';
import '../widgets/add_clothing_bottom_sheet.dart'; // [CONFIG] Sesuaikan path import

// ============================================================
// ADD CLOTHING PAGE (gambar 1)
// ============================================================

class ClothingCategoryItem {
  final String id;
  final String label;
  final String imagePath;
  final int count;

  const ClothingCategoryItem({
    required this.id,
    required this.label,
    required this.imagePath,
    required this.count,
  });
}

class AddClothingPage extends StatefulWidget {
  const AddClothingPage({super.key});

  @override
  State<AddClothingPage> createState() => _AddClothingPageState();
}

class _AddClothingPageState extends State<AddClothingPage> {
  // [CONFIG] Data kategori
  final List<ClothingCategoryItem> _categories = const [
    ClothingCategoryItem(id: 'outer', label: 'Outer', imagePath: 'assets/images/outer.png', count: 3),
    ClothingCategoryItem(id: 'top', label: 'Top', imagePath: 'assets/images/top.png', count: 10),
    ClothingCategoryItem(id: 'bags', label: 'Bags', imagePath: 'assets/images/bags.png', count: 6),
    ClothingCategoryItem(id: 'bottom', label: 'Bottom', imagePath: 'assets/images/bottom.png', count: 8),
    ClothingCategoryItem(id: 'accessories', label: 'Accessories', imagePath: 'assets/images/accessories.png', count: 9),
    ClothingCategoryItem(id: 'shoes', label: 'Shoes', imagePath: 'assets/images/shoes.png', count: 9),
    ClothingCategoryItem(id: 'dresses', label: 'Dresses', imagePath: 'assets/images/dresses.png', count: 5),
  ];

  int _selectedCount = 3; // [CONFIG] Ganti dengan state dari controller
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEF0),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 6),
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildUploadButton(),
                    const SizedBox(height: 24),
                    _buildCategoryGrid(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── Bottom Action Bar (widget terpisah) ───────────
            AddClothingBottomBar(
              selectedCount: _selectedCount,
              onCancel: () => Navigator.pop(context),
              onAdd: () {
                // TODO: Simpan item ke wardrobe via controller
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: const [
          Spacer(),
          Text(
            'MIXÉRA',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 2, color: Color(0xFFE8A0B0)),
          ),
          Spacer(),
          Icon(Icons.notifications_none_rounded, color: Color(0xFFE8A0B0), size: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Text(
          'Add Clothes',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: Color(0xFF2D2D2D)),
        ),
        SizedBox(height: 4),
        Text(
          'Upload and organize new\nitems for your wardrobe',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Buka image picker
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF4A7BB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('Upload Photos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.88,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = _selectedCategoryId == category.id;
        return _SelectableCategoryCard(
          category: category,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedCategoryId = isSelected ? null : category.id;
            });
          },
        );
      },
    );
  }
}

// ── Selectable Category Card ────────────────────────────────────────
class _SelectableCategoryCard extends StatelessWidget {
  final ClothingCategoryItem category;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableCategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? Border.all(color: const Color(0xFFF4A7BB), width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? const Color(0xFFF4A7BB) : const Color(0xFF2D2D2D),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('${category.count}', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Center(
                  child: Image.asset(
                    category.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEEF0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}