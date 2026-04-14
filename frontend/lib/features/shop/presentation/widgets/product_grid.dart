import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../data/models/product_model.dart';
import '../controllers/shop_controller.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  final void Function(ProductModel) onTap;

  const ProductGrid({super.key, required this.products, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.58,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(product: products[i], onTap: onTap),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final void Function(ProductModel) onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  late bool _wishlisted;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _wishlisted = widget.product.isWishlisted;
  }

  @override
  void didUpdateWidget(_ProductCard old) {
    super.didUpdateWidget(old);
    if (old.product.isWishlisted != widget.product.isWishlisted) {
      _wishlisted = widget.product.isWishlisted;
    }
  }

  Future<void> _toggleWishlist() async {
    if (_busy) return;
    final wasWishlisted = _wishlisted;
    setState(() {
      _busy = true;
      _wishlisted = !_wishlisted; // optimistic
    });
    try {
      final result = await Get.find<ShopController>()
          .toggleWishlistByProduct(widget.product.id);
      if (!mounted) return;
      setState(() => _wishlisted = result);
      Get.snackbar(
        '',
        result ? 'Ditambahkan ke wishlist' : 'Dihapus dari wishlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.softWhite,
        colorText: AppColors.primaryText,
        duration: const Duration(milliseconds: 1500),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(
          result ? Icons.favorite : Icons.favorite_border_rounded,
          color: AppColors.blushPink,
          size: 20,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _wishlisted = wasWishlisted); // revert
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(str[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return GestureDetector(
      onTap: () => widget.onTap(product),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.softWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: product.primaryImage != null
                        ? Image.network(
                            product.primaryImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
                  ),
                  if (product.isNew)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.blushPink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('New',
                            style: AppTextStyles.small.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _toggleWishlist,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _wishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: AppColors.blushPink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: AppTextStyles.productName.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (product.color.isNotEmpty)
                      Text(product.color,
                          style: AppTextStyles.small,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    if (product.discountPrice != null) ...[
                      Text(
                        _formatRupiah(product.price),
                        style: AppTextStyles.small.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      Text(_formatRupiah(product.discountPrice!),
                          style: AppTextStyles.type.copyWith(color: AppColors.blushPink)),
                    ] else
                      Text(_formatRupiah(product.price),
                          style: AppTextStyles.type.copyWith(color: AppColors.blushPink)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.roseMist,
      child: const Icon(Icons.image_outlined, size: 40, color: AppColors.blushPink),
    );
  }
}
