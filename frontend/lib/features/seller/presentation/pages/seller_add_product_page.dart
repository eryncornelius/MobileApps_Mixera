import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../wardrobe/data/models/wardrobe_api_models.dart';
import '../controllers/seller_controller.dart';

class _VariantRow {
  _VariantRow({required this.size, String stockText = '0'}) : stock = TextEditingController(text: stockText);
  String size;
  final TextEditingController stock;
  void dispose() => stock.dispose();
}

class SellerAddProductPage extends StatefulWidget {
  const SellerAddProductPage({super.key});

  @override
  State<SellerAddProductPage> createState() => _SellerAddProductPageState();
}

class _SellerAddProductPageState extends State<SellerAddProductPage> {
  static const _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  final _name = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();
  final _optionalImageUrl = TextEditingController();
  final List<_VariantRow> _rows = [_VariantRow(size: 'M', stockText: '0')];
  bool _saving = false;
  bool _uploadingImage = false;
  String? _localPreviewPath;
  String? _uploadedImageUrl;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _desc.dispose();
    _optionalImageUrl.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    final used = _rows.map((r) => r.size).toSet();
    final next = _sizes.firstWhere((s) => !used.contains(s), orElse: () => '');
    if (next.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua ukuran sudah dipakai.')),
      );
      return;
    }
    setState(() => _rows.add(_VariantRow(size: next, stockText: '0')));
  }

  void _removeRow(int i) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows[i].dispose();
      _rows.removeAt(i);
    });
  }

  String _effectiveImageUrl() {
    final uploaded = (_uploadedImageUrl ?? '').trim();
    if (uploaded.isNotEmpty) return uploaded;
    return _optionalImageUrl.text.trim();
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
        _uploadedImageUrl = url;
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

  Future<void> _save() async {
    final name = _name.text.trim();
    final price = int.tryParse(_price.text.trim().replaceAll(RegExp(r'\D'), ''));
    if (name.isEmpty || price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan harga wajib diisi.')),
      );
      return;
    }
    final variants = <Map<String, dynamic>>[];
    for (final r in _rows) {
      final st = int.tryParse(r.stock.text.trim());
      if (st == null || st < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stok tidak valid untuk ukuran ${r.size}.')),
        );
        return;
      }
      variants.add({'size': r.size, 'stock': st});
    }
    setState(() => _saving = true);
    try {
      final c = Get.find<SellerController>();
      await c.createProduct(
        name: name,
        price: price,
        description: _desc.text.trim(),
        imageUrl: _effectiveImageUrl(),
        variants: variants,
        stock: variants.first['stock'] as int,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        elevation: 0,
        title: Text('Produk baru', style: AppTextStyles.headline.copyWith(fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
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
                      TextField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Nama produk'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _price,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                      ),
                      const SizedBox(height: 16),
                      Text('Foto produk (opsional)', style: AppTextStyles.type),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _localPreviewPath != null
                                ? Image.file(
                                    File(_localPreviewPath!),
                                    width: 88,
                                    height: 88,
                                    fit: BoxFit.cover,
                                  )
                                : _uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty
                                    ? Image.network(
                                        resolveMediaUrl(_uploadedImageUrl),
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
                                      )
                                    : Container(
                                        width: 88,
                                        height: 88,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.softWhite,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Icon(Icons.image_outlined, color: AppColors.secondaryText.withOpacity(0.6)),
                                      ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _uploadingImage ? null : _pickAndUploadPhoto,
                                  icon: _uploadingImage
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.photo_library_outlined, size: 18),
                                  label: Text(_uploadingImage ? 'Mengunggah…' : 'Pilih dari galeri'),
                                ),
                                if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty)
                                  TextButton(
                                    onPressed: _uploadingImage
                                        ? null
                                        : () => setState(() {
                                              _uploadedImageUrl = null;
                                              _localPreviewPath = null;
                                            }),
                                    child: Text('Hapus foto', style: AppTextStyles.small.copyWith(color: AppColors.secondaryText)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Atau tempel URL gambar jika punya tautan sendiri.',
                        style: AppTextStyles.small.copyWith(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _optionalImageUrl,
                        decoration: const InputDecoration(
                          labelText: 'URL gambar (opsional)',
                          isDense: true,
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
                      Row(
                        children: [
                          Text('Varian & Stok', style: AppTextStyles.section),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _addRow,
                            icon: const Icon(Icons.add, size: 18, color: AppColors.blushPink),
                            label: Text('Ukuran', style: AppTextStyles.small.copyWith(color: AppColors.blushPink)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_rows.length, (i) {
                        final r = _rows[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: r.size,
                                  decoration: const InputDecoration(labelText: 'Ukuran', isDense: true),
                                  items: _sizes
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          enabled: !_rows.any((x) => x != r && x.size == s),
                                          child: Text(s),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() => r.size = v);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: r.stock,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Stok', isDense: true),
                                ),
                              ),
                              IconButton(
                                onPressed: _rows.length <= 1 ? null : () => _removeRow(i),
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                        );
                      }),
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
                    : const Text('Simpan Produk', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
