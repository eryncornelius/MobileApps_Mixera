import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/shop_controller.dart';
import '../widgets/product_grid.dart';
import '../widgets/search_history_section.dart';
import '../widgets/shop_search_bar.dart';

const _popularSearches = [
  'Midi skirt', 'Blouse', 'Sweater', 'Cute Tops', 'Dress', 'Floral Dress', 'Crop Tops', 'Pastel', 'Pink',
];

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  bool _hasQuery = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    setState(() => _hasQuery = v.trim().isNotEmpty);
    if (v.trim().isEmpty) {
      Get.find<ShopController>().searchResults.clear();
    }
  }

  void _onSubmit(String v) {
    if (v.trim().isNotEmpty) Get.find<ShopController>().search(v.trim());
  }

  void _fillQuery(String q) {
    _controller.text = q;
    setState(() => _hasQuery = true);
    Get.find<ShopController>().search(q);
  }

  @override
  Widget build(BuildContext context) {
    final shopC = Get.find<ShopController>();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left_rounded,
                        size: 28, color: AppColors.primaryText),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'MIXÉRA',
                        style: AppTextStyles.logo
                            .copyWith(color: AppColors.blushPink, letterSpacing: 2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Search field — single outline (no theme + container double border)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ShopSearchTextField(
                controller: _controller,
                autofocus: true,
                clearVisible: _hasQuery,
                onClear: () {
                  _controller.clear();
                  setState(() => _hasQuery = false);
                  shopC.searchResults.clear();
                },
                onChanged: _onChanged,
                onSubmitted: _onSubmit,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                // Show results if searching or has results
                if (shopC.isSearching.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.blushPink),
                  );
                }

                if (_hasQuery && shopC.searchResults.isNotEmpty) {
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ProductGrid(
                        products: shopC.searchResults,
                        onTap: (p) => Navigator.pushNamed(
                          context,
                          RouteNames.productDetail,
                          arguments: p.slug,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }

                if (_hasQuery && shopC.searchResults.isEmpty) {
                  return Center(
                    child: Text('No results found', style: AppTextStyles.description),
                  );
                }

                // Default: recent + popular searches
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    SearchHistorySection(
                      title: 'Recent Searches',
                      items: shopC.recentSearches,
                      onTap: _fillQuery,
                      onClearAll: shopC.clearRecentSearches,
                    ),
                    const SizedBox(height: 16),
                    SearchHistorySection(
                      title: 'Popular Searches',
                      items: _popularSearches,
                      onTap: _fillQuery,
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
