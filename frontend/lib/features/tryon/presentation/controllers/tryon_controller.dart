import 'dart:async';

import 'package:get/get.dart';

import '../../data/datasources/tryon_remote_datasource.dart';
import '../../data/models/tryon_api_models.dart';

enum TryOnGenState { idle, submitting, polling, done, failed }

class TryOnController extends GetxController {
  final TryOnRemoteDatasource _ds = TryOnRemoteDatasource();

  final personImages      = <PersonProfileImageModel>[].obs;
  final isLoadingImages   = false.obs;
  final isUploading       = false.obs;
  final isActivating      = false.obs;

  /// Currently chosen person image for the next try-on request.
  final selectedPersonImageId = Rxn<int>();

  final lastRequest = Rxn<TryOnRequestDetailModel>();

  /// Fine-grained generation lifecycle (replaces the old bool flags).
  final genState = TryOnGenState.idle.obs;

  final isSavingTryOnResult = false.obs;
  final savedTryOnEntries = <TryOnSavedEntryModel>[].obs;

  /// Convenience getters consumed by the UI.
  bool get isSubmitting => genState.value == TryOnGenState.submitting;
  bool get isPolling    => genState.value == TryOnGenState.polling;
  bool get isBusy       =>
      genState.value == TryOnGenState.submitting ||
      genState.value == TryOnGenState.polling;

  // Polling internals
  Timer? _pollTimer;
  int    _pollGuard = 0;
  static const _maxPolls    = 40;   // 40 × 500 ms = 20 s ceiling
  static const _pollInterval = Duration(milliseconds: 500);

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  void clearLastRequest() {
    _pollTimer?.cancel();
    lastRequest.value = null;
    genState.value = TryOnGenState.idle;
    _pollGuard = 0;
  }

  // ── Person image management ───────────────────────────────────────────────

  Future<void> refreshPersonImages() async {
    isLoadingImages.value = true;
    try {
      personImages.value = await _ds.listPersonImages();
      PersonProfileImageModel? active;
      for (final p in personImages) {
        if (p.isActive) { active = p; break; }
      }
      if (active != null) {
        selectedPersonImageId.value = active.id;
      } else if (personImages.isNotEmpty) {
        selectedPersonImageId.value ??= personImages.first.id;
      }
    } catch (e) {
      Get.snackbar('Try-on', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoadingImages.value = false;
    }
  }

  Future<void> uploadPersonImage(String path, {bool setActive = true}) async {
    isUploading.value = true;
    try {
      final img = await _ds.uploadPersonImage(path, setActive: setActive);
      await refreshPersonImages();
      selectedPersonImageId.value = img.id;
    } catch (e) {
      Get.snackbar('Try-on', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> activatePersonImage(int imageId) async {
    isActivating.value = true;
    try {
      await _ds.activatePersonImage(imageId);
      selectedPersonImageId.value = imageId;
      await refreshPersonImages();
    } catch (e) {
      Get.snackbar('Try-on', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isActivating.value = false;
    }
  }

  /// Hides photo from library; server keeps file + row for past try-on requests.
  Future<void> archivePersonImage(int imageId) async {
    try {
      await _ds.archivePersonImage(imageId);
      await refreshPersonImages();
      if (selectedPersonImageId.value == imageId) {
        if (personImages.isEmpty) {
          selectedPersonImageId.value = null;
        } else {
          PersonProfileImageModel? preferred;
          for (final p in personImages) {
            if (p.isActive) {
              preferred = p;
              break;
            }
          }
          preferred ??= personImages.first;
          selectedPersonImageId.value = preferred.id;
        }
      }
    } catch (e) {
      Get.snackbar('Try-on', e.toString().replaceAll('Exception: ', ''));
    }
  }

  void selectPersonImage(int id) => selectedPersonImageId.value = id;

  // ── Try-on generation (non-blocking) ─────────────────────────────────────

  /// Creates the try-on request, then **returns immediately** while polling
  /// happens in the background.  The UI should observe [genState] and
  /// [lastRequest] reactively — no awaiting needed after this call.
  Future<void> submitTryOn({
    required TryOnSourceKind sourceType,
    int? mixResultId,
    int? shopProductId,
  }) async {
    final pid = selectedPersonImageId.value;
    if (pid == null) {
      Get.snackbar('Try-on', 'Pilih atau unggah foto tubuh Anda terlebih dahulu.');
      return;
    }

    _pollTimer?.cancel();
    _pollGuard = 0;
    genState.value = TryOnGenState.submitting;

    try {
      final req = await _ds.createTryOnRequest(
        personImageId: pid,
        sourceType: sourceType,
        mixResultId: mixResultId,
        shopProductId: shopProductId,
      );
      lastRequest.value = req;

      // If the backend already finished (unlikely but possible):
      if (_isTerminal(req.status)) {
        genState.value = req.status == 'completed'
            ? TryOnGenState.done
            : TryOnGenState.failed;
        return;
      }

      // Start background polling — UI is already on the result page.
      genState.value = TryOnGenState.polling;
      _pollTimer = Timer.periodic(_pollInterval, _onPollTick);
    } catch (e) {
      genState.value = TryOnGenState.failed;
      Get.snackbar('Try-on', e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _onPollTick(Timer t) async {
    if (_pollGuard++ >= _maxPolls) {
      t.cancel();
      genState.value = TryOnGenState.failed;
      Get.snackbar('Try-on', 'Waktu tunggu habis. Coba lagi.');
      return;
    }

    final current = lastRequest.value;
    if (current == null) { t.cancel(); return; }

    try {
      final updated = await _ds.getTryOnRequest(current.id);
      lastRequest.value = updated;

      if (_isTerminal(updated.status)) {
        t.cancel();
        genState.value = updated.status == 'completed'
            ? TryOnGenState.done
            : TryOnGenState.failed;
      }
    } catch (_) {
      // Transient network error — keep polling, don't fail yet.
    }
  }

  static bool _isTerminal(String status) =>
      status == 'completed' || status == 'failed';

  // ── Favourites / saved list (for home section) ─────────────────────────

  Future<void> refreshSavedTryOnResults() async {
    try {
      savedTryOnEntries.value = await _ds.listSavedTryOnResults();
    } catch (e) {
      savedTryOnEntries.clear();
    }
  }

  /// Load a try-on request (e.g. saved result detail → person photo + status).
  Future<TryOnRequestDetailModel?> fetchTryOnRequest(int requestId) async {
    try {
      return await _ds.getTryOnRequest(requestId);
    } catch (e) {
      Get.snackbar('Try-on', e.toString().replaceAll('Exception: ', ''));
      return null;
    }
  }

  /// Toggle favourite by result id; refreshes [savedTryOnEntries]. Returns new `is_saved`.
  Future<bool> toggleSaveTryOnResultById(int resultId) async {
    isSavingTryOnResult.value = true;
    try {
      final saved = await _ds.toggleTryOnSave(resultId);
      final cur = lastRequest.value;
      if (cur?.result?.id == resultId) {
        lastRequest.value = cur!.copyWith(
          result: cur.result!.copyWith(isSaved: saved),
        );
      }
      await refreshSavedTryOnResults();
      return saved;
    } catch (e) {
      Get.snackbar('Try-on', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isSavingTryOnResult.value = false;
    }
  }

  Future<void> toggleSaveCurrentTryOnResult() async {
    final res = lastRequest.value?.result;
    if (res == null) return;
    isSavingTryOnResult.value = true;
    try {
      final saved = await _ds.toggleTryOnSave(res.id);
      final cur = lastRequest.value;
      if (cur != null && cur.result != null) {
        lastRequest.value = cur.copyWith(
          result: cur.result!.copyWith(isSaved: saved),
        );
      }
      await refreshSavedTryOnResults();
    } catch (e) {
      Get.snackbar('Try-on', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isSavingTryOnResult.value = false;
    }
  }
}
