import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../tryon/data/models/tryon_api_models.dart';
import '../../../tryon/presentation/controllers/tryon_controller.dart';

/// Kelola foto tubuh untuk virtual try-on: tambah dari galeri, arsip, pilih default.
/// Satu [Obx] di root — hindari [Obx] di dalam [ListView.builder] (GetX improper-use warning).
class PersonPhotosPage extends StatefulWidget {
  const PersonPhotosPage({super.key});

  @override
  State<PersonPhotosPage> createState() => _PersonPhotosPageState();
}

class _PersonPhotosPageState extends State<PersonPhotosPage> {
  TryOnController get _c => Get.find<TryOnController>();
  bool _openedRefresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_openedRefresh && mounted) {
        _openedRefresh = true;
        _c.refreshPersonImages();
      }
    });
  }

  Future<void> _addPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 88);
    if (file == null) return;
    final first = _c.personImages.isEmpty;
    await _c.uploadPersonImage(file.path, setActive: first);
  }

  Future<void> _confirmArchive(PersonProfileImageModel p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sembunyikan foto?', style: AppTextStyles.section),
        content: Text(
          'Foto tidak dihapus dari server: riwayat try-on & preview tersimpan. '
          'Foto hanya hilang dari daftar pilihan di sini dan di halaman Try-On.',
          style: AppTextStyles.description,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: AppTextStyles.productName.copyWith(color: AppColors.secondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sembunyikan', style: AppTextStyles.productName.copyWith(color: AppColors.blushPink)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await _c.archivePersonImage(p.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Foto tubuh (Try-On)',
          style: AppTextStyles.headline.copyWith(fontSize: 22),
        ),
      ),
      body: Obx(() {
        // Satu scope reaktif: jangan Obx lagi di dalam itemBuilder.
        final loading = _c.isLoadingImages.value;
        final uploading = _c.isUploading.value;
        final activating = _c.isActivating.value;
        final n = _c.personImages.length;

        if (loading && n == 0) {
          return const Center(child: CircularProgressIndicator(color: AppColors.blushPink));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                'Tambah foto untuk dipakai di halaman Try-On. Bisa menambah, menjadikan default, '
                'atau menyembunyikan dari daftar (data tetap aman untuk riwayat try-on) — tidak ada pengubahan nama.',
                style: AppTextStyles.description.copyWith(height: 1.4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: uploading ? null : _addPhoto,
                  icon: uploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.add_photo_alternate_outlined, size: 22),
                  label: Text(
                    uploading ? 'Mengunggah…' : 'Tambah foto',
                    style: AppTextStyles.button,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blushPink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: n == 0
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Belum ada foto. Tap "Tambah foto" untuk memilih dari galeri.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.description,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.blushPink,
                      onRefresh: () => _c.refreshPersonImages(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: n,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final p = _c.personImages[i];
                          return _PersonTile(
                            item: p,
                            canSetDefault: !p.isActive && !activating,
                            onSetDefault: () => _c.activatePersonImage(p.id),
                            onArchive: () => _confirmArchive(p),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _PersonTile extends StatelessWidget {
  final PersonProfileImageModel item;
  final bool canSetDefault;
  final VoidCallback onSetDefault;
  final VoidCallback onArchive;

  const _PersonTile({
    required this.item,
    required this.canSetDefault,
    required this.onSetDefault,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final url = tryonResolveMediaUrl(item.image);
    return Material(
      color: AppColors.softWhite,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: url.isNotEmpty
                  ? Image.network(
                      url,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ph(),
                    )
                  : _ph(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foto #${item.id}',
                    style: AppTextStyles.productName.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (item.uploadedAt != null)
                    Text(
                      _fmt(item.uploadedAt!),
                      style: AppTextStyles.small.copyWith(color: AppColors.secondaryText),
                    ),
                  if (item.isActive) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blushPink.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Default try-on',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.blushPink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canSetDefault)
                  TextButton(
                    onPressed: onSetDefault,
                    child: Text(
                      'Jadikan default',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.blushPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: onArchive,
                  icon: const Icon(Icons.visibility_off_outlined, color: AppColors.roseMist),
                  tooltip: 'Sembunyikan dari daftar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  Widget _ph() => Container(
        width: 72,
        height: 72,
        color: AppColors.warmCream,
        child: const Icon(Icons.person_outline, color: AppColors.roseMist, size: 36),
      );
}
