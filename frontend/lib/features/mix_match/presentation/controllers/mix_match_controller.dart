import 'package:get/get.dart';

import '../../../wardrobe/data/datasources/wardrobe_remote_datasource.dart';
import '../../../wardrobe/data/models/wardrobe_api_models.dart';
import '../../data/datasources/mix_match_remote_datasource.dart';
import '../../data/models/mix_match_api_models.dart';

class MixMatchController extends GetxController {
  final MixMatchRemoteDatasource _mix = MixMatchRemoteDatasource();
  final WardrobeRemoteDatasource _wardrobe = WardrobeRemoteDatasource();

  final currentSession = Rxn<MixSessionModel>();
  final currentResult = Rxn<MixResultDetailModel>();

  final pickerItems = <WardrobeItemApiModel>[].obs;
  final isLoadingPicker = false.obs;

  /// Recent wardrobe items for Mix tab spotlight (GET `/wardrobe/items/`).
  final spotlightItems = <WardrobeItemApiModel>[].obs;
  final isLoadingSpotlight = false.obs;

  final isBusy = false.obs;

  /// Selected wardrobe item ids (max 5). Categories tracked for top+bottom rule.
  final selectedItemIds = <int>[].obs;
  final Map<int, String> _itemCategory = {};

  final isSavingResult = false.obs;

  /// Favourited mix results (GET `/mixmatch/results/saved/`).
  final savedMixOutfits = <MixResultDetailModel>[].obs;

  bool get hasTopAndBottom {
    final cats = _itemCategory.values.toSet();
    return cats.contains('top') && cats.contains('bottom');
  }

  bool isSelected(int id) => selectedItemIds.contains(id);

  void toggleItem(WardrobeItemApiModel item) {
    if (selectedItemIds.contains(item.id)) {
      selectedItemIds.remove(item.id);
      _itemCategory.remove(item.id);
    } else {
      if (selectedItemIds.length >= 5) {
        Get.snackbar('Mix', 'Maksimal 5 item per sesi.');
        return;
      }
      selectedItemIds.add(item.id);
      _itemCategory[item.id] = item.category;
    }
    selectedItemIds.refresh();
  }

  void clearSelection() {
    selectedItemIds.clear();
    _itemCategory.clear();
    selectedItemIds.refresh();
  }

  Future<void> startNewSession() async {
    isBusy.value = true;
    try {
      final s = await _mix.createSession();
      currentSession.value = s;
      clearSelection();
      currentResult.value = null;
    } catch (e) {
      Get.snackbar('Mix', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isBusy.value = false;
    }
  }

  /// Loads up to [limit] items for the Mix home horizontal list.
  Future<void> loadSpotlightItems({int limit = 12}) async {
    isLoadingSpotlight.value = true;
    try {
      final all = await _wardrobe.getWardrobeItems();
      spotlightItems.value = all.length <= limit ? all : all.sublist(0, limit);
    } catch (e) {
      spotlightItems.clear();
      Get.snackbar('Wardrobe', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoadingSpotlight.value = false;
    }
  }

  Future<void> loadPickerCategory(String categorySlug) async {
    isLoadingPicker.value = true;
    try {
      pickerItems.value = await _wardrobe.getWardrobeItems(category: categorySlug);
    } catch (e) {
      pickerItems.clear();
      Get.snackbar('Wardrobe', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoadingPicker.value = false;
    }
  }

  Future<MixSessionModel?> submitSelection() async {
    final sid = currentSession.value?.id;
    if (sid == null) {
      Get.snackbar('Mix', 'Sesi tidak ditemukan.');
      return null;
    }
    if (selectedItemIds.isEmpty) {
      Get.snackbar('Mix', 'Pilih minimal satu item.');
      return null;
    }
    if (!hasTopAndBottom) {
      Get.snackbar('Mix', 'Pilih minimal satu atasan (top) dan satu bawahan (bottom).');
      return null;
    }
    isBusy.value = true;
    try {
      final s = await _mix.selectItems(sid, List<int>.from(selectedItemIds));
      currentSession.value = s;
      return s;
    } catch (e) {
      Get.snackbar('Mix', e.toString().replaceAll('Exception: ', ''));
      return null;
    } finally {
      isBusy.value = false;
    }
  }

  Future<MixResultDetailModel?> generateMix() async {
    final sid = currentSession.value?.id;
    if (sid == null) return null;
    isBusy.value = true;
    try {
      final r = await _mix.generate(sid);
      currentResult.value = r;
      return r;
    } catch (e) {
      Get.snackbar('Mix', e.toString().replaceAll('Exception: ', ''));
      return null;
    } finally {
      isBusy.value = false;
    }
  }

  Future<bool> toggleSave(int resultId) async {
    isSavingResult.value = true;
    try {
      final saved = await _mix.toggleSaveResult(resultId);
      final cur = currentResult.value;
      if (cur != null && cur.id == resultId) {
        currentResult.value = cur.copyWith(isSaved: saved);
      }
      await refreshSavedMixOutfits();
      return saved;
    } catch (e) {
      Get.snackbar('Mix', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isSavingResult.value = false;
    }
  }

  Future<MixResultDetailModel?> refreshResult(int resultId) async {
    try {
      final r = await _mix.getResult(resultId);
      currentResult.value = r;
      return r;
    } catch (e) {
      Get.snackbar('Mix', e.toString().replaceAll('Exception: ', ''));
      return null;
    }
  }

  Future<void> refreshSavedMixOutfits() async {
    try {
      savedMixOutfits.value = await _mix.listSavedMixResults();
    } catch (e) {
      savedMixOutfits.clear();
    }
  }
}
