import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../tryon/data/models/tryon_api_models.dart';
import '../../../tryon/presentation/pages/try_on_result_page.dart';
import '../../data/models/product_detail_model.dart';
import '../controllers/shop_controller.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_image_carousel.dart';

class ProductDetailPage extends StatefulWidget {
  final String slug;
  const ProductDetailPage({super.key, required this.slug});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  ProductDetailModel? _product;
  bool _loading = true;
  ProductVariantModel? _selectedVariant;
  bool _wishlistBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final detail = await Get.find<ShopController>().getProductDetail(widget.slug);
    if (mounted) {
      setState(() {
        _product = detail;
        _loading = false;
        if (detail != null && detail.variants.isNotEmpty) {
          _selectedVariant = detail.variants.first;
        }
      });
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

  Future<void> _addToCart() async {
    if (_selectedVariant == null) return;
    final cartC = Get.find<CartController>();
    await cartC.addItem(_selectedVariant!.id, 1);
    if (mounted) {
      Get.snackbar(
        'Keranjang',
        'Produk berhasil ditambahkan!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.blushPink,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        mainButton: TextButton(
          onPressed: () {
            Get.closeCurrentSnackbar();
            Navigator.pushNamed(context, RouteNames.cart);
          },
          child: const Text('Lihat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }
  }

  String _normalizeWhatsappPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('0')) return '62${digits.substring(1)}';
    if (digits.startsWith('62')) return digits;
    return digits;
  }

  Future<void> _chatSeller(ProductDetailModel p) async {
    final phone = _normalizeWhatsappPhone(p.sellerPhone);
    if (phone.isEmpty) {
      Get.snackbar(
        'Chat seller',
        'Nomor WhatsApp penjual belum tersedia.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final store = p.sellerStoreName.isNotEmpty ? p.sellerStoreName : 'penjual';
    final text =
        'Halo $store, saya ingin tanya detail produk ${p.name} (ID: ${p.id}, slug: ${p.slug}).';
    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(text)}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      Get.snackbar(
        'Chat seller',
        'Tidak bisa membuka WhatsApp.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _toggleWishlist(ProductDetailModel p) async {
    if (_wishlistBusy) return;
    setState(() => _wishlistBusy = true);
    try {
      final saved = await Get.find<ShopController>().toggleWishlistByProduct(p.id);
      if (!mounted) return;
      Get.snackbar(
        '',
        saved ? 'Ditambahkan ke wishlist' : 'Dihapus dari wishlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.softWhite,
        colorText: AppColors.primaryText,
        duration: const Duration(milliseconds: 1500),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(
          saved ? Icons.favorite : Icons.favorite_border_rounded,
          color: AppColors.blushPink,
          size: 20,
        ),
      );
      setState(() {
        _product = ProductDetailModel(
          id: p.id,
          name: p.name,
          slug: p.slug,
          price: p.price,
          discountPrice: p.discountPrice,
          categoryName: p.categoryName,
          categorySlug: p.categorySlug,
          color: p.color,
          isNew: p.isNew,
          isActive: p.isActive,
          moderationFlagged: p.moderationFlagged,
          moderationNote: p.moderationNote,
          totalStock: p.totalStock,
          primaryImage: p.primaryImage,
          description: p.description,
          images: p.images,
          variants: p.variants,
          sellerId: p.sellerId,
          sellerStoreName: p.sellerStoreName,
          sellerPhone: p.sellerPhone,
          isWishlisted: saved,
        );
      });
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('Wishlist', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _wishlistBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.blushPink))
            : _product == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Product not found', style: AppTextStyles.description),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Go back')),
                      ],
                    ),
                  )
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final p = _product!;
    final shopC = Get.find<ShopController>();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildAppBar()),
        SliverToBoxAdapter(
          child: ProductImageCarousel(images: p.images),
        ),
        SliverToBoxAdapter(
          child: _buildPriceCard(p),
        ),
        SliverToBoxAdapter(
          child: _buildDetails(p),
        ),
        SliverToBoxAdapter(
          child: _buildSizeSelector(p),
        ),
        SliverToBoxAdapter(
          child: _buildActionButtons(p),
        ),
        SliverToBoxAdapter(
          child: _buildTryOnCta(p),
        ),
        // Related products
        if (shopC.products.length > 1) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text('You May Also Like', style: AppTextStyles.section),
            ),
          ),
          SliverToBoxAdapter(
            child: ProductGrid(
              products: shopC.products.where((pr) => pr.slug != p.slug).take(4).toList(),
              onTap: (pr) => Navigator.pushReplacementNamed(
                context,
                RouteNames.productDetail,
                arguments: pr.slug,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_rounded, size: 24, color: AppColors.primaryText),
          ),
          Expanded(
            child: Center(
              child: Text(
                'MIXÉRA',
                style: AppTextStyles.logo.copyWith(color: AppColors.blushPink, letterSpacing: 2),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, RouteNames.cart),
            child: const Icon(Icons.shopping_bag_outlined, size: 24, color: AppColors.primaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(ProductDetailModel p) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(color: AppColors.roseMist),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p.discountPrice != null) ...[
                  Row(
                    children: [
                      Text(
                        _formatRupiah(p.price),
                        style: AppTextStyles.description.copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.softWhite,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${p.discountPercent}%',
                          style: AppTextStyles.small.copyWith(color: AppColors.primaryText),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.blushPink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${p.discountPercent}% OFF',
                          style: AppTextStyles.small.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(_formatRupiah(p.discountPrice!),
                      style: AppTextStyles.headline.copyWith(color: AppColors.primaryText)),
                ] else
                  Text(_formatRupiah(p.price),
                      style: AppTextStyles.headline.copyWith(color: AppColors.primaryText)),
                if (p.color.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.softWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(p.color, style: AppTextStyles.small),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: _wishlistBusy ? null : () => _toggleWishlist(p),
            child: Icon(
              p.isWishlisted ? Icons.favorite : Icons.favorite_border_rounded,
              color: AppColors.blushPink,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(ProductDetailModel p) {
    final lines = p.description.split('\n').where((l) => l.trim().isNotEmpty).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product details', style: AppTextStyles.type),
                const SizedBox(height: 6),
                if (lines.isEmpty)
                  Text(p.description.isEmpty ? 'No description.' : p.description,
                      style: AppTextStyles.description)
                else
                  ...lines.map((l) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: AppTextStyles.description),
                            Expanded(child: Text(l.trim(), style: AppTextStyles.description)),
                          ],
                        ),
                      )),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(p.name,
              style: AppTextStyles.section.copyWith(fontSize: 15),
              textAlign: TextAlign.right),
        ],
      ),
    );
  }

  Widget _buildSizeSelector(ProductDetailModel p) {
    if (p.variants.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ukuran:', style: AppTextStyles.type),
          const SizedBox(height: 10),
          Row(
            children: p.variants.map((v) {
              final selected = _selectedVariant?.id == v.id;
              final outOfStock = v.stock == 0;
              return GestureDetector(
                onTap: outOfStock ? null : () => setState(() => _selectedVariant = v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 10),
                  width: 52,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.blushPink : AppColors.softWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.blushPink : AppColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    v.size,
                    style: AppTextStyles.type.copyWith(
                      color: outOfStock
                          ? AppColors.secondaryText
                          : selected
                              ? Colors.white
                              : AppColors.primaryText,
                      decoration: outOfStock ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildTryOnCta(ProductDetailModel p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TryOnResultPage(
                  sourceType: TryOnSourceKind.shopProduct,
                  shopProductId: p.id,
                ),
              ),
            );
          },
          icon: const Icon(Icons.checkroom_outlined, color: AppColors.blushPink),
          label: Text(
            'Virtual try-on',
            style: AppTextStyles.button.copyWith(color: AppColors.primaryText),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.blushPink),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ProductDetailModel p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _chatSeller(p),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.blushPink),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('Chat Penjual',
                  style: AppTextStyles.button.copyWith(color: AppColors.blushPink)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() {
              final isUpdating = Get.find<CartController>().isUpdating.value;
              return ElevatedButton(
                onPressed: _selectedVariant == null || isUpdating ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isUpdating
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Keranjang'),
              );
            }),
          ),
        ],
      ),
    );
  }
}
