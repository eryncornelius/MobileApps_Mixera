import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../data/models/product_model.dart';

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
        childAspectRatio: 0.65,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(product: products[i], onTap: onTap),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final void Function(ProductModel) onTap;

  const _ProductCard({required this.product, required this.onTap});

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
    return GestureDetector(
      onTap: () => onTap(product),
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
            // Image area
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: product.primaryImage != null
                        ? Image.network(
                            product.primaryImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => _imagePlaceholder(),
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
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border_rounded,
                          size: 16, color: AppColors.blushPink),
                    ),
                  ),
                ],
              ),
            ),
            // Info area
            Padding(
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
                        style: AppTextStyles.small, maxLines: 1, overflow: TextOverflow.ellipsis),
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
