import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/routes/route_names.dart';
import '../../../shop/presentation/controllers/shop_controller.dart';
import '../../../shop/data/models/product_model.dart';
import '../../../wardrobe/data/models/wardrobe_api_models.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late final ShopController _shop;

  @override
  void initState() {
    super.initState();
    _shop = Get.find<ShopController>();
    _shop.loadWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText, size: 20),
        ),
        title: Text('Wishlist', style: AppTextStyles.headline.copyWith(fontSize: 22)),
      ),
      body: Obx(() {
        if (_shop.isLoadingWishlist.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.blushPink),
          );
        }
        final items = _shop.wishlist;
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border_rounded, size: 48, color: AppColors.blushPink),
                  const SizedBox(height: 12),
                  Text('Wishlist kamu masih kosong', style: AppTextStyles.section),
                  const SizedBox(height: 6),
                  Text(
                    'Simpan produk yang kamu suka dari halaman katalog.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.description,
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _shop.loadWishlist,
          color: AppColors.blushPink,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _WishlistTile(
              item: items[i],
              onOpen: () => Navigator.pushNamed(
                context,
                RouteNames.productDetail,
                arguments: items[i].slug,
              ),
              onToggle: () async {
                await _shop.toggleWishlistByProduct(items[i].id);
              },
            ),
          ),
        );
      }),
    );
  }
}

class _WishlistTile extends StatelessWidget {
  final ProductModel item;
  final VoidCallback onOpen;
  final Future<void> Function() onToggle;

  const _WishlistTile({
    required this.item,
    required this.onOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final img = resolveMediaUrl(item.primaryImage);
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.softWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: img.isEmpty
                  ? Container(
                      width: 72,
                      height: 72,
                      color: AppColors.roseMist,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_outlined, color: AppColors.secondaryText),
                    )
                  : Image.network(
                      img,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 72,
                        height: 72,
                        color: AppColors.roseMist,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined, color: AppColors.secondaryText),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: AppTextStyles.type, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (item.categoryName != null && item.categoryName!.isNotEmpty)
                    Text(item.categoryName!, style: AppTextStyles.small.copyWith(color: AppColors.secondaryText)),
                  const SizedBox(height: 4),
                  Text('Rp ${item.displayPrice}', style: AppTextStyles.section.copyWith(fontSize: 14)),
                ],
              ),
            ),
            IconButton(
              onPressed: onToggle,
              icon: const Icon(Icons.favorite, color: AppColors.blushPink),
            ),
          ],
        ),
      ),
    );
  }
}
