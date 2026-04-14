import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shop/data/models/product_detail_model.dart';
import '../../../shop/data/models/product_model.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../wardrobe/data/models/wardrobe_api_models.dart';
import '../controllers/seller_controller.dart';

class SellerEditProductPage extends StatefulWidget {
  final ProductModel product;
  const SellerEditProductPage({super.key, required this.product});

  @override
  State<SellerEditProductPage> createState() => _SellerEditProductPageState();
}

class _SellerEditProductPageState extends State<SellerEditProductPage> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _discountPrice;
  late final TextEditingController _color;
  late final TextEditingController _desc;
  final List<TextEditingController> _variantStockCtrls = [];
  late bool _active;
  bool _loadingDetail = true;
  bool _saving = false;
  bool _uploadingImage = false;
  String? _loadError;
  ProductDetailModel? _detail;
  /// Foto baru yang sudah diunggah; diterapkan saat simpan (PATCH).
  String? _pendingImageUrl;
  String? _localPreviewPath;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p.name);
    _price = TextEditingController(text: '${p.price}');
    _discountPrice = TextEditingController();
    _color = TextEditingController();
    _desc = TextEditingController();
    _active = p.isActive;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loadingDetail = true;
      _loadError = null;
    });
    final d = await Get.find<SellerController>().loadProductDetail(widget.product.id);
    if (!mounted) return;
    if (d == null) {
      setState(() {
        _loadingDetail = false;
        _loadError = 'Gagal memuat detail produk.';
      });
      return;
    }
    for (final c in _variantStockCtrls) {
      c.dispose();
    }
    _variantStockCtrls.clear();
    for (final v in d.variants) {
      _variantStockCtrls.add(TextEditingController(text: '${v.stock}'));
    }
    setState(() {
      _detail = d;
      _name.text = d.name;
      _price.text = '${d.price}';
      _discountPrice.text = d.discountPrice != null ? '${d.discountPrice}' : '';
      _color.text = d.color;
      _desc.text = d.description;
      _active = d.isActive;
      _loadingDetail = false;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _discountPrice.dispose();
    _color.dispose();
    _desc.dispose();
    for (final c in _variantStockCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  static const _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  Future<void> _showAddVariant() async {
    final detail = _detail;
    if (detail == null) return;
    final taken = detail.variants.map((v) => v.size).toSet();
    final choices = _sizes.where((s) => !taken.contains(s)).toList();
    if (choices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua ukuran sudah ada.')),
      );
      return;
    }
    String pick = choices.first;
    final stockCtrl = TextEditingController(text: '0');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Varian baru', style: AppTextStyles.type),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatefulBuilder(
              builder: (context, setSt) => DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: pick,
                decoration: const InputDecoration(labelText: 'Ukuran'),
                items: choices.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setSt(() => pick = v ?? pick),
              ),
            ),
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stok awal'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tambah')),
        ],
      ),
    );
    if (ok != true || !mounted) {
      stockCtrl.dispose();
      return;
    }
    final st = int.tryParse(stockCtrl.text.trim());
    stockCtrl.dispose();
    if (st == null || st < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok tidak valid.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await Get.find<SellerController>().updateProduct(
        id: widget.product.id,
        variantsAdd: [
          {'size': pick, 'stock': st},
        ],
        imageUrl: _pendingImageUrl,
      );
      await _fetchDetail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Varian ditambahkan.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final price = int.tryParse(_price.text.trim().replaceAll(RegExp(r'\D'), ''));
    if (name.isEmpty || price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan harga wajib valid.')),
      );
      return;
    }

    final discountRaw = _discountPrice.text.trim().replaceAll(RegExp(r'\D'), '');
    final discountPrice = discountRaw.isEmpty ? null : int.tryParse(discountRaw);
    final clearDiscount = discountRaw.isEmpty && (_detail?.discountPrice != null);
    if (discountRaw.isNotEmpty && (discountPrice == null || discountPrice >= price)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga diskon harus lebih kecil dari harga normal.')),
      );
      return;
    }

    final detail = _detail;
    List<Map<String, int>>? variantStocks;
    if (detail != null && detail.variants.isNotEmpty) {
      if (_variantStockCtrls.length != detail.variants.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data varian tidak sinkron, tarik untuk refresh.')),
        );
        return;
      }
      variantStocks = [];
      for (var i = 0; i < detail.variants.length; i++) {
        final st = int.tryParse(_variantStockCtrls[i].text.trim());
        if (st == null || st < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Stok tidak valid untuk ukuran ${detail.variants[i].size}.')),
          );
          return;
        }
        variantStocks.add({'variant_id': detail.variants[i].id, 'stock': st});
      }
    }

    setState(() => _saving = true);
    try {
      await Get.find<SellerController>().updateProduct(
        id: widget.product.id,
        name: name,
        price: price,
        discountPrice: discountPrice,
        clearDiscountPrice: clearDiscount,
        description: _desc.text.trim(),
        color: _color.text.trim(),
        isActive: _active,
        variantStocks: variantStocks,
        imageUrl: _pendingImageUrl,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 88,
    );
    if (x == null) return;
    setState(() {
      _localPreviewPath = x.path;
      _uploadingImage = true;
    });
    try {
      final url = await Get.find<SellerController>().uploadProductImage(x.path);
      if (!mounted) return;
      setState(() {
        _pendingImageUrl = url;
        _localPreviewPath = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
        setState(() => _localPreviewPath = null);
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  String? _displayImageRef() {
    if (_pendingImageUrl != null && _pendingImageUrl!.isNotEmpty) return _pendingImageUrl;
    return _detail?.primaryImage ?? widget.product.primaryImage;
  }

  Widget _buildProductThumb() {
    if (_localPreviewPath != null) {
      return Image.file(
        File(_localPreviewPath!),
        width: 88,
        height: 88,
        fit: BoxFit.cover,
      );
    }
    final ref = _displayImageRef();
    if (ref == null || ref.isEmpty) {
      return Container(
        width: 88,
        height: 88,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.softWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          Icons.image_outlined,
          color: AppColors.secondaryText.withOpacity(0.6),
        ),
      );
    }
    return Image.network(
      resolveMediaUrl(ref),
      width: 88,
      height: 88,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 88,
        height: 88,
        color: AppColors.border,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        elevation: 0,
        title: Text('Edit produk', style: AppTextStyles.headline.copyWith(fontSize: 18)),
      ),
      body: _loadingDetail
          ? const Center(child: CircularProgressIndicator(color: AppColors.blushPink))
          : _loadError != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_loadError!, style: AppTextStyles.description),
                      TextButton(onPressed: _fetchDetail, child: const Text('Coba lagi')),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          if (_detail?.moderationFlagged == true) ...[
                            Material(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  'Produk ditandai moderasi. Tidak tampil di etalase pembeli sampai admin mencabut flag.\n'
                                  '${_detail!.moderationNote.isNotEmpty ? _detail!.moderationNote : ''}',
                                  style: AppTextStyles.small,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.softWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Informasi Dasar', style: AppTextStyles.section),
                                const SizedBox(height: 16),
                                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama')),
                                const SizedBox(height: 8),
                                Text(
                                  'Mengubah nama memperbarui slug toko otomatis.',
                                  style: AppTextStyles.small.copyWith(color: AppColors.secondaryText),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _price,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _discountPrice,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Harga diskon (Rp) — opsional',
                                    hintText: 'Kosongkan untuk hapus diskon',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _color,
                                  decoration: const InputDecoration(
                                    labelText: 'Warna — opsional',
                                    hintText: 'Contoh: Hitam, Navy Blue',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _desc,
                                  maxLines: 3,
                                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.softWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Foto produk', style: AppTextStyles.section),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _buildProductThumb(),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: (_loadingDetail || _saving || _uploadingImage)
                                                ? null
                                                : _pickAndUploadPhoto,
                                            icon: _uploadingImage
                                                ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  )
                                                : const Icon(Icons.photo_library_outlined, size: 18),
                                            label: Text(_uploadingImage ? 'Mengunggah…' : 'Ganti foto'),
                                          ),
                                          if (_pendingImageUrl != null && _pendingImageUrl!.isNotEmpty)
                                            Text(
                                              'Foto baru diterapkan setelah Anda menyimpan.',
                                              style: AppTextStyles.small.copyWith(color: AppColors.secondaryText),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.softWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Stok per ukuran', style: AppTextStyles.section),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: _loadingDetail || _saving ? null : _showAddVariant,
                                      icon: const Icon(Icons.add, size: 18, color: AppColors.blushPink),
                                      label: Text('Ukuran', style: AppTextStyles.small.copyWith(color: AppColors.blushPink)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (_detail != null && _detail!.variants.isEmpty)
                                  Text('Tidak ada varian.', style: AppTextStyles.description)
                                else
                                  ...List.generate(_detail?.variants.length ?? 0, (i) {
                                    final v = _detail!.variants[i];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: TextField(
                                        controller: _variantStockCtrls[i],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Stok — ukuran ${v.size}',
                                        ),
                                      ),
                                    );
                                  }),
                                const SizedBox(height: 16),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Aktif di etalase', style: AppTextStyles.type),
                                  value: _active,
                                  activeTrackColor: AppColors.roseMist,
                                  activeThumbColor: AppColors.blushPink,
                                  onChanged: (v) => setState(() => _active = v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.softWhite,
                        border: const Border(top: BorderSide(color: AppColors.border)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blushPink,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
