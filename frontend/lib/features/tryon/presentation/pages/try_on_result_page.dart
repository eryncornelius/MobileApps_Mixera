import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/tryon_api_models.dart';
import '../controllers/tryon_controller.dart';

/// Virtual try-on page.
///
/// Entry flow:
///   1. User selects / uploads a person photo.
///   2. Taps "Generate try-on" → controller creates the request and starts
///      background polling immediately (non-blocking).
///   3. Page reacts to [TryOnController.genState]:
///        idle      → person-picker UI
///        submitting / polling → animated generating screen
///        done      → result screen with the composed image
///        failed    → error screen with retry
class TryOnResultPage extends StatefulWidget {
  final TryOnSourceKind sourceType;
  final int? mixResultId;
  final int? shopProductId;

  const TryOnResultPage({
    super.key,
    required this.sourceType,
    this.mixResultId,
    this.shopProductId,
  });

  @override
  State<TryOnResultPage> createState() => _TryOnResultPageState();
}

class _TryOnResultPageState extends State<TryOnResultPage>
    with SingleTickerProviderStateMixin {
  late final TryOnController _tryOn;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  bool _isSharing = false;

  bool get _sourceOk {
    switch (widget.sourceType) {
      case TryOnSourceKind.mixResult:
        return widget.mixResultId != null;
      case TryOnSourceKind.shopProduct:
        return widget.shopProductId != null;
    }
  }

  @override
  void initState() {
    super.initState();
    _tryOn = Get.find<TryOnController>();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _tryOn.clearLastRequest();
    _tryOn.refreshPersonImages();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    await _tryOn.uploadPersonImage(file.path, setActive: true);
  }

  Future<void> _runTryOn() async {
    if (!_sourceOk) return;
    // submitTryOn is now non-blocking — it kicks off polling and returns.
    // genState drives the UI transition automatically via Obx.
    await _tryOn.submitTryOn(
      sourceType: widget.sourceType,
      mixResultId: widget.mixResultId,
      shopProductId: widget.shopProductId,
    );
  }

  Future<void> _retry() async {
    await _runTryOn();
  }

  @override
  Widget build(BuildContext context) {
    if (!_sourceOk) {
      return Scaffold(
        backgroundColor: AppColors.warmCream,
        appBar: _appBar(),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              widget.sourceType == TryOnSourceKind.mixResult
                  ? 'ID hasil mix tidak tersedia. Selesaikan generate outfit terlebih dahulu.'
                  : 'Produk tidak valid untuk try-on.',
              textAlign: TextAlign.center,
              style: AppTextStyles.description,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: _appBar(),
      body: Obx(() {
        switch (_tryOn.genState.value) {
          case TryOnGenState.submitting:
          case TryOnGenState.polling:
            return _buildGenerating();
          case TryOnGenState.done:
            return _buildResult();
          case TryOnGenState.failed:
            return _buildFailed();
          case TryOnGenState.idle:
            return _buildPersonPicker();
        }
      }),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios,
            color: AppColors.primaryText, size: 20),
        onPressed: () {
          _tryOn.clearLastRequest();
          Navigator.pop(context);
        },
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.notifications_none,
              color: AppColors.blushPink, size: 28),
        ),
      ],
    );
  }

  // ── Person picker (idle) ──────────────────────────────────────────────────

  Widget _buildPersonPicker() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'MIXÉRA',
            style: AppTextStyles.logo
                .copyWith(color: AppColors.blushPink, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Virtual Try-On',
            style: AppTextStyles.headline
                .copyWith(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Foto tubuh Anda dipakai hanya untuk try-on — terpisah dari wardrobe.',
            style: AppTextStyles.description,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Person image list
          Obx(() {
            if (_tryOn.isLoadingImages.value && _tryOn.personImages.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.blushPink)),
              );
            }
            if (_tryOn.personImages.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Belum ada foto tubuh. Unggah foto agar bisa mencoba outfit.',
                  style: AppTextStyles.description,
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pilih foto tubuh', style: AppTextStyles.section),
                const SizedBox(height: 12),
                ..._tryOn.personImages
                    .map((p) => _personImageTile(p)),
              ],
            );
          }),

          const SizedBox(height: 12),

          // Upload button
          Obx(() => OutlinedButton.icon(
                onPressed: _tryOn.isUploading.value ? null : _pickAndUpload,
                icon: _tryOn.isUploading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.blushPink),
                      )
                    : const Icon(Icons.add_a_photo_outlined,
                        color: AppColors.blushPink),
                label: Text(
                  'Unggah foto tubuh',
                  style:
                      AppTextStyles.button.copyWith(color: AppColors.primaryText),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.blushPink),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
              )),

          const SizedBox(height: 24),

          // Generate button
          Obx(() {
            final canSubmit = _tryOn.selectedPersonImageId.value != null &&
                _tryOn.personImages.isNotEmpty &&
                !_tryOn.isUploading.value;
            return SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: canSubmit ? _runTryOn : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blushPink,
                  disabledBackgroundColor:
                      AppColors.blushPink.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: Text('Generate try-on', style: AppTextStyles.button),
              ),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _personImageTile(PersonProfileImageModel p) {
    return Obx(() {
      final selected = _tryOn.selectedPersonImageId.value == p.id;
      final url = tryonResolveMediaUrl(p.image);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: AppColors.softWhite,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _tryOn.selectPersonImage(p.id),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.blushPink : AppColors.border,
                  width: selected ? 2 : 1.5,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: url.isNotEmpty
                        ? Image.network(url,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _thumbPh())
                        : _thumbPh(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.label.isNotEmpty ? p.label : 'Foto #${p.id}',
                          style: AppTextStyles.productName,
                        ),
                        if (p.isActive)
                          Text(
                            'Aktif',
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.blushPink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!p.isActive)
                    Obx(() => TextButton(
                          onPressed: _tryOn.isActivating.value
                              ? null
                              : () => _tryOn.activatePersonImage(p.id),
                          child: const Text('Set active'),
                        )),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _thumbPh() => Container(
        width: 64,
        height: 64,
        color: AppColors.warmCream,
        child: const Icon(Icons.person, color: AppColors.roseMist, size: 32),
      );

  // ── Generating (submitting / polling) ────────────────────────────────────

  Widget _buildGenerating() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MIXÉRA',
              style: AppTextStyles.logo
                  .copyWith(color: AppColors.blushPink, fontSize: 22),
            ),
            const SizedBox(height: 32),

            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, _) => Opacity(
                opacity: _pulseAnim.value,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: AppColors.roseMist.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline,
                      color: AppColors.blushPink, size: 64),
                ),
              ),
            ),
            const SizedBox(height: 32),

            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                  color: AppColors.blushPink, strokeWidth: 3),
            ),
            const SizedBox(height: 24),

            Obx(() => Text(
                  _tryOn.genState.value == TryOnGenState.submitting
                      ? 'Preparing your try-on…'
                      : 'Generating your result…',
                  style: AppTextStyles.headline.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 10),
            Text(
              'Applying your selected outfit onto the photo. This may take a moment.',
              style: AppTextStyles.description,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Share ─────────────────────────────────────────────────────────────────

  Future<void> _shareImage() async {
    final req = _tryOn.lastRequest.value;
    final imgUrl =
        req?.result != null ? tryonResolveMediaUrl(req!.result!.resultImage) : '';
    if (imgUrl.isEmpty) return;

    setState(() => _isSharing = true);
    try {
      final tempFile = File(
        '${Directory.systemTemp.path}/mixera_tryon_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await Dio().download(imgUrl, tempFile.path);
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Check out my virtual try-on result from Mixéra! 👗✨',
      );
    } catch (_) {
      // Fallback: share URL as text if download fails
      await Share.share(
        'Check out my virtual try-on from Mixéra! 👗✨\n$imgUrl',
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  // ── Done ─────────────────────────────────────────────────────────────────

  Widget _buildResult() {
    final req = _tryOn.lastRequest.value;
    final res = req?.result;
    final imgUrl = res != null ? tryonResolveMediaUrl(res.resultImage) : '';

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'MIXÉRA',
            style: AppTextStyles.logo
                .copyWith(color: AppColors.blushPink, fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            'Try-On Result',
            style: AppTextStyles.headline
                .copyWith(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Full image without cropping (API may return portrait or square)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxH = (MediaQuery.sizeOf(context).height * 0.58)
                    .clamp(280.0, 620.0);
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxH,
                      maxWidth: constraints.maxWidth,
                    ),
                    child: ColoredBox(
                      color: AppColors.roseMist.withValues(alpha: 0.12),
                      child: imgUrl.isNotEmpty
                          ? Image.network(
                              imgUrl,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return _resultLoadingBox();
                              },
                              errorBuilder: (_, _, _) => _resultPlaceholder(),
                            )
                          : _resultPlaceholder(),
                    ),
                  ),
                );
              },
            ),
          ),

          if (res != null && res.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.softWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  res.notes,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.description,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Obx(() {
              final liveRes = _tryOn.lastRequest.value?.result;
              if (liveRes == null) return const SizedBox.shrink();
              final busy = _tryOn.isSavingTryOnResult.value;
              final fav = liveRes.isSaved;
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: busy ? null : () => _tryOn.toggleSaveCurrentTryOnResult(),
                  icon: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.blushPink,
                          ),
                        )
                      : Icon(
                          fav ? Icons.favorite : Icons.favorite_border,
                          color: AppColors.blushPink,
                        ),
                  label: Text(
                    fav ? 'Saved to favourites' : 'Add to favourites',
                    style: AppTextStyles.button.copyWith(color: AppColors.primaryText),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSharing ? null : _shareImage,
                icon: _isSharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _isSharing ? 'Sharing…' : 'Share',
                  style: AppTextStyles.button,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blushPink,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blushPink.withValues(alpha: 0.85),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: Text('Done', style: AppTextStyles.button),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _resultLoadingBox() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, _) => Container(
        color: AppColors.roseMist.withValues(alpha: _pulseAnim.value * 0.25),
        child: const Center(
          child: CircularProgressIndicator(
              color: AppColors.blushPink, strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _resultPlaceholder() {
    return Container(
      color: AppColors.roseMist.withValues(alpha: 0.35),
      child: const Center(
        child: Icon(Icons.person, color: AppColors.roseMist, size: 120),
      ),
    );
  }

  // ── Failed ────────────────────────────────────────────────────────────────

  Widget _buildFailed() {
    final req = _tryOn.lastRequest.value;
    final notes = req?.result?.notes ?? '';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.roseMist, size: 64),
            const SizedBox(height: 20),
            Text(
              'Try-on gagal',
              style: AppTextStyles.headline.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                notes,
                style: AppTextStyles.description,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blushPink,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: Text('Coba lagi', style: AppTextStyles.button),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
                child: Text(
                  'Kembali',
                  style:
                      AppTextStyles.button.copyWith(color: AppColors.primaryText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
