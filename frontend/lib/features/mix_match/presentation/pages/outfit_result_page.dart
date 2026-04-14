import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../tryon/data/models/tryon_api_models.dart';
import '../../../tryon/presentation/pages/try_on_result_page.dart';
import '../../../wardrobe/data/models/wardrobe_api_models.dart';
import '../../data/models/mix_match_api_models.dart';
import '../controllers/mix_match_controller.dart';

/// Mix result screen — drives its own generation lifecycle.
///
/// On entry (initState) it calls [MixMatchController.generateMix] and shows
/// a generating state while the backend processes.  When the result arrives
/// it either renders the composed preview_image or falls back to an item strip.
///
/// States:
///   _generating  → spinner + message
///   _failed      → error card + retry button
///   _done        → result card (preview image + AI text + action buttons)
class OutfitResultPage extends StatefulWidget {
  /// When provided, skips generation and shows this result directly.
  final MixResultDetailModel? preloadedResult;

  const OutfitResultPage({super.key, this.preloadedResult});

  @override
  State<OutfitResultPage> createState() => _OutfitResultPageState();
}

enum _ResultState { generating, done, failed }

class _OutfitResultPageState extends State<OutfitResultPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final MixMatchController _mix;
  _ResultState _state = _ResultState.generating;
  MixResultDetailModel? _result;
  String _errorMessage = '';
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mix = Get.find<MixMatchController>();

    // Pulsing animation for the generating screen
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.preloadedResult != null) {
        setState(() {
          _result = widget.preloadedResult;
          _state = _ResultState.done;
        });
      } else {
        _generate();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_state != _ResultState.generating) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        if (_pulseCtrl.isAnimating) _pulseCtrl.stop();
      case AppLifecycleState.resumed:
        if (mounted && _state == _ResultState.generating && !_pulseCtrl.isAnimating) {
          _pulseCtrl.repeat(reverse: true);
        }
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _generate() async {
    if (!mounted) return;
    setState(() {
      _state = _ResultState.generating;
      _errorMessage = '';
    });

    final result = await _mix.generateMix();
    if (!mounted) return;

    if (result != null) {
      setState(() {
        _result = result;
        _state = _ResultState.done;
      });
    } else {
      setState(() {
        _errorMessage = 'Gagal membuat outfit. Coba lagi.';
        _state = _ResultState.failed;
      });
    }
  }

  Future<void> _toggleSave() async {
    final r = _result;
    if (r == null) return;
    final v = await _mix.toggleSave(r.id);
    if (mounted) {
      setState(() => _result = r.copyWith(isSaved: v));
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.notifications_none, color: AppColors.blushPink, size: 28),
          ),
        ],
      ),
      body: switch (_state) {
        _ResultState.generating => _buildGenerating(),
        _ResultState.failed     => _buildFailed(),
        _ResultState.done       => _buildResult(_result!),
      },
    );
  }

  // ── Generating ────────────────────────────────────────────────────────────

  Widget _buildGenerating() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Brand
            Text(
              'MIXÉRA',
              style: AppTextStyles.logo.copyWith(
                color: AppColors.blushPink,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 32),

            // Animated outfit icon
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, _) => Opacity(
                opacity: _pulseAnim.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.roseMist.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.checkroom_outlined,
                    color: AppColors.blushPink,
                    size: 56,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Spinner
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                color: AppColors.blushPink,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),

            // Messages
            Text(
              'Generating your outfit preview…',
              style: AppTextStyles.headline.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'AI is analysing your items and composing a styled look.',
              style: AppTextStyles.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Kamu boleh meminimise aplikasi atau pindah layar lain — proses tetap jalan di server '
              'selama koneksi internet tidak terputus. Buka lagi halaman ini untuk melihat hasil.',
              style: AppTextStyles.small.copyWith(
                color: AppColors.secondaryText,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Failed ────────────────────────────────────────────────────────────────

  Widget _buildFailed() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.roseMist, size: 64),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: AppTextStyles.headline.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage,
              style: AppTextStyles.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blushPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Text('Try again', style: AppTextStyles.button),
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
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  'Go back',
                  style: AppTextStyles.button.copyWith(color: AppColors.primaryText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Done ──────────────────────────────────────────────────────────────────

  Widget _buildResult(MixResultDetailModel r) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'MIXÉRA',
            style: AppTextStyles.logo.copyWith(
              color: AppColors.blushPink,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mix Outfit Result',
            style: AppTextStyles.headline.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            r.styleLabel,
            style: AppTextStyles.section.copyWith(color: AppColors.blushPink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Score: ${r.score} / 100',
            style: AppTextStyles.type.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          // ── Preview image ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              height: 340,
              decoration: BoxDecoration(
                color: AppColors.roseMist.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: _previewWidget(r),
            ),
          ),

          const SizedBox(height: 16),

          // ── Info card ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Your outfit has been created!',
                    style: AppTextStyles.headline.copyWith(fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    r.explanation.isNotEmpty ? r.explanation : '—',
                    style: AppTextStyles.description,
                    textAlign: TextAlign.center,
                  ),
                  if (r.tips.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.blushPink.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.tips_and_updates_outlined,
                              color: AppColors.blushPink, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              r.tips,
                              style: AppTextStyles.description.copyWith(
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Action buttons ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                // Save / favourites
                Obx(() {
                  final saving = _mix.isSavingResult.value;
                  final saved = _result?.isSaved ?? r.isSaved;
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: saving ? null : _toggleSave,
                      icon: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.blushPink),
                            )
                          : Icon(
                              saved ? Icons.favorite : Icons.favorite_border,
                              color: AppColors.blushPink,
                            ),
                      label: Text(
                        saved ? 'Saved' : 'Add to Favourites',
                        style: AppTextStyles.button.copyWith(color: AppColors.primaryText),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.softWhite,
                        side: BorderSide(color: AppColors.border, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 14),

                // Virtual try-on
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TryOnResultPage(
                            sourceType: TryOnSourceKind.mixResult,
                            mixResultId: r.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_outline, color: AppColors.softWhite),
                    label: Text('Try on with a person!', style: AppTextStyles.button),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blushPink,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Mix again
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blushPink.withValues(alpha: 0.75),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                      elevation: 0,
                    ),
                    child: Text('Mix again', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Preview image widget ──────────────────────────────────────────────────

  /// Prefer the single backend-composed preview_image.
  /// Fall back to per-item strip only when there is no preview.
  Widget _previewWidget(MixResultDetailModel r) {
    final preview = r.previewImage;
    if (preview != null && preview.isNotEmpty) {
      final url = resolveMediaUrl(preview);
      if (url.isNotEmpty) {
        return Image.network(
          url,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _previewLoadingShimmer();
          },
          errorBuilder: (_, _, _) => _itemStripFallback(r.selectedItems),
        );
      }
    }
    return _itemStripFallback(r.selectedItems);
  }

  Widget _previewLoadingShimmer() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, _) => Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.roseMist
            .withValues(alpha: _pulseAnim.value * 0.25),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.blushPink,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  /// Item strip shown when backend has no preview image.
  Widget _itemStripFallback(List<WardrobeItemApiModel> items) {
    if (items.isEmpty) {
      return const Center(
        child: Icon(Icons.checkroom, color: AppColors.roseMist, size: 100),
      );
    }
    if (items.length == 1) {
      final url = resolveMediaUrl(items.first.image);
      if (url.isEmpty) {
        return const Center(
          child: Icon(Icons.checkroom, color: AppColors.roseMist, size: 100),
        );
      }
      return Image.network(
        url,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _previewLoadingShimmer(),
        errorBuilder: (_, _, _) => const Center(
          child: Icon(Icons.checkroom, color: AppColors.roseMist, size: 100),
        ),
      );
    }
    // 2-column grid of up to 4 items
    final display = items.take(4).toList();
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: display.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (_, i) {
          final url = resolveMediaUrl(display[i].image);
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: url.isNotEmpty
                ? Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.warmCream,
                      child: const Icon(Icons.checkroom,
                          color: AppColors.roseMist),
                    ),
                  )
                : Container(
                    color: AppColors.warmCream,
                    child: const Icon(Icons.checkroom,
                        color: AppColors.roseMist),
                  ),
          );
        },
      ),
    );
  }
}
