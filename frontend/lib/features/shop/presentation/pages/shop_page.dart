import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/shop_controller.dart';
import '../widgets/category_tabs.dart';
import '../widgets/product_grid.dart';
import '../widgets/shop_search_bar.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shopC = Get.find<ShopController>();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.blushPink,
          onRefresh: shopC.refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverToBoxAdapter(child: CategoryTabs()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              Obx(() {
                if (shopC.isLoadingProducts.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.blushPink),
                      ),
                    ),
                  );
                }
                if (shopC.products.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text('No products found', style: AppTextStyles.description),
                      ),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: ProductGrid(
                    products: shopC.products,
                    onTap: (p) => Navigator.pushNamed(
                      context,
                      RouteNames.productDetail,
                      arguments: p.slug,
                    ),
                  ),
                );
              }),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'MIXÉRA',
                    style: AppTextStyles.logo
                        .copyWith(color: AppColors.blushPink, letterSpacing: 2),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, RouteNames.cart),
                child: const Icon(Icons.shopping_bag_outlined,
                    size: 24, color: AppColors.primaryText),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Shop', style: AppTextStyles.headline),
          const SizedBox(height: 2),
          Text('Discover Items you\'ll Love', style: AppTextStyles.description),
          const SizedBox(height: 16),
          ShopSearchBarPlaceholder(
            onTap: () => Navigator.pushNamed(context, RouteNames.shopSearch),
          ),
        ],
      ),
    );
  }
}
