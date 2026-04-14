import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../tryon/data/models/tryon_api_models.dart';
import '../../../tryon/presentation/controllers/tryon_controller.dart';
import '../../../wardrobe/data/models/wardrobe_api_models.dart';

/// Full preview + metadata for one saved try-on (from [SavedTryOnPhotosPage]).
class SavedTryOnDetailPage extends StatefulWidget {
  final TryOnSavedEntryModel entry;

  const SavedTryOnDetailPage({super.key, required this.entry});

  @override
  State<SavedTryOnDetailPage> createState() => _SavedTryOnDetailPageState();
}

class _SavedTryOnDetailPageState extends State<SavedTryOnDetailPage> {
  late final TryOnController _tryOn;
  TryOnRequestDetailModel? _request;
  bool _loadingRequest = true;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _tryOn = Get.find<TryOnController>();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    setState(() => _loadingRequest = true);
    final r = await _tryOn.fetchTryOnRequest(widget.entry.requestId);
    if (mounted) {
      setState(() {
        _request = r;
        _loadingRequest = false;
      });
    }
  }

  String _sourceLabel() {
    switch (widget.entry.sourceType) {
      case 'shop_product':
        return 'From shop product';
      case 'mix_result':
        return 'From mix outfit';
      default:
        return widget.entry.sourceType;
    }
  }

  String _dateLine() {
    final d = widget.entry.createdAt;
    if (d == null) return '—';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _shareImage() async {
    final imgUrl = tryonResolveMediaUrl(widget.entry.resultImage);
    if (imgUrl.isEmpty) return;

    setState(() => _isSharing = true);
    try {
      final tempFile = File(
        '${Directory.systemTemp.path}/mixera_tryon_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await Dio().download(imgUrl, tempFile.path);
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Check out my virtual try-on result from Mixéra!',
      );
    } catch (_) {
      await Share.share(
        'Check out my virtual try-on from Mixéra!\n$imgUrl',
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _toggleSaved() async {
    final saved = await _tryOn.toggleSaveTryOnResultById(widget.entry.id);
    if (!mounted) return;
    if (!saved) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgUrl = tryonResolveMediaUrl(widget.entry.resultImage);

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
          'Try-on preview',
          style: AppTextStyles.headline.copyWith(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _sourceLabel(),
              style: AppTextStyles.small.copyWith(
                color: AppColors.blushPink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dateLine(),
              style: AppTextStyles.small.copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 16),
            if (_loadingRequest)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blushPink),
                  ),
                ),
              )
            else if (_request != null) ...[
              _personRow(_request!.personImage),
              const SizedBox(height: 16),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final maxH = (MediaQuery.sizeOf(context).height * 0.55).clamp(260.0, 560.0);
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ColoredBox(
                    color: AppColors.roseMist.withValues(alpha: 0.12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: maxH,
                        maxWidth: constraints.maxWidth,
                      ),
                      child: imgUrl.isEmpty
                          ? SizedBox(
                              height: 200,
                              child: Center(
                                child: Icon(Icons.image_not_supported_outlined,
                                    size: 56, color: AppColors.secondaryText.withValues(alpha: 0.6)),
                              ),
                            )
                          : InteractiveViewer(
                              minScale: 0.85,
                              maxScale: 3.5,
                              child: Image.network(
                                imgUrl,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return SizedBox(
                                    height: 220,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.blushPink,
                                        value: progress.expectedTotalBytes != null
                                            ? progress.cumulativeBytesLoaded /
                                                progress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Icon(Icons.broken_image_outlined,
                                        size: 56, color: AppColors.secondaryText.withValues(alpha: 0.6)),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
            if (widget.entry.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.softWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  widget.entry.notes,
                  style: AppTextStyles.description,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Obx(() {
              final busy = _tryOn.isSavingTryOnResult.value;
              return SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: busy ? null : _toggleSaved,
                  icon: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blushPink),
                        )
                      : const Icon(Icons.favorite, color: AppColors.blushPink),
                  label: Text(
                    'Remove from saved',
                    style: AppTextStyles.button.copyWith(color: AppColors.primaryText),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSharing || imgUrl.isEmpty ? null : _shareImage,
                icon: _isSharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(_isSharing ? 'Sharing…' : 'Share', style: AppTextStyles.button),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blushPink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _personRow(PersonProfileImageModel p) {
    final u = resolveMediaUrl(p.image);
    return Material(
      color: AppColors.softWhite,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: u.isNotEmpty
                  ? Image.network(
                      u,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _personPh(),
                    )
                  : _personPh(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your photo', style: AppTextStyles.productName.copyWith(fontSize: 14)),
                  Text(
                    p.label.isNotEmpty ? p.label : 'Person #${p.id}',
                    style: AppTextStyles.small.copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _personPh() => Container(
        width: 52,
        height: 52,
        color: AppColors.warmCream,
        child: const Icon(Icons.person, color: AppColors.roseMist, size: 28),
      );
}
