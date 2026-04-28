import 'package:get/get.dart';

import '../../data/datasources/wardrobe_remote_datasource.dart';
import '../../data/models/wardrobe_api_models.dart';

class WardrobeController extends GetxController {
  final WardrobeRemoteDatasource _ds = WardrobeRemoteDatasource();

  final categorySummary = <WardrobeCategorySummaryEntry>[].obs;
  final categoryItems = <WardrobeItemApiModel>[].obs;

  final isLoadingSummary = false.obs;
  final isLoadingItems = false.obs;
  final isUploading = false.obs;
  final isConfirming = false.obs;

  /// Currently selected style/occasion filter. Empty string = no filter.
  final selectedStyleTag = ''.obs;

  /// True when showing only favourite items.
  final isFavouritesFilter = false.obs;

  /// All unique style tags across loaded items, sorted alphabetically.
  List<String> get availableStyleTags {
    final tags = <String>{};
    for (final item in categoryItems) {
      tags.addAll(item.styleTags);
    }
    return tags.toList()..sort();
  }

  /// Items filtered by [selectedStyleTag] or [isFavouritesFilter].
  List<WardrobeItemApiModel> get filteredCategoryItems {
    final items = categoryItems.toList();
    if (isFavouritesFilter.value) {
      return items.where((i) => i.isFavourite).toList();
    }
    final tag = selectedStyleTag.value;
    if (tag.isEmpty) return items;
    return items.where((i) => i.styleTags.contains(tag)).toList();
  }

  void clearStyleTagFilter() {
    selectedStyleTag.value = '';
    isFavouritesFilter.value = false;
  }

  void setFavouritesFilter() {
    selectedStyleTag.value = '';
    isFavouritesFilter.value = true;
  }

  /// Batch the user can return to from the main wardrobe screen (e.g. after upload).
  final Rxn<UploadBatchDetailModel> pendingReviewBatch = Rxn<UploadBatchDetailModel>();

  @override
  void onInit() {
    super.onInit();
    loadCategorySummary();
  }

  Future<void> loadCategorySummary() async {
    isLoadingSummary.value = true;
    try {
      final raw = await _ds.getCategorySummary();
      final bySlug = {for (final e in raw) e.category: e.count};
      categorySummary.value = kWardrobeCategorySlugOrder
          .map(
            (slug) => WardrobeCategorySummaryEntry(
              category: slug,
              count: bySlug[slug] ?? 0,
            ),
          )
          .toList();
    } catch (e) {
      Get.snackbar('Wardrobe', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoadingSummary.value = false;
    }
  }

  Future<void> loadItemsForCategory(String category) async {
    selectedStyleTag.value = '';
    isFavouritesFilter.value = false;
    isLoadingItems.value = true;
    try {
      categoryItems.value = await _ds.getWardrobeItems(category: category);
    } catch (e) {
      categoryItems.clear();
      Get.snackbar('Wardrobe', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoadingItems.value = false;
    }
  }

  Future<UploadBatchDetailModel?> uploadPhotos(List<String> paths) async {
    if (paths.isEmpty) return null;
    isUploading.value = true;
    try {
      final batch = await _ds.createUploadBatch(paths);
      pendingReviewBatch.value = batch;
      return batch;
    } catch (e) {
      Get.snackbar('Upload', e.toString().replaceAll('Exception: ', ''));
      return null;
    } finally {
      isUploading.value = false;
    }
  }

  Future<UploadBatchDetailModel?> refreshBatch(int batchId) async {
    try {
      final batch = await _ds.getUploadBatchDetail(batchId);
      pendingReviewBatch.value = batch;
      return batch;
    } catch (e) {
      Get.snackbar('Wardrobe', e.toString().replaceAll('Exception: ', ''));
      return null;
    }
  }

  Future<List<WardrobeItemApiModel>?> confirmReviewBatch(int batchId) async {
    isConfirming.value = true;
    try {
      final items = await _ds.confirmBatch(batchId);
      pendingReviewBatch.value = null;
      await loadCategorySummary();
      return items;
    } catch (e) {
      Get.snackbar('Wardrobe', e.toString().replaceAll('Exception: ', ''));
      return null;
    } finally {
      isConfirming.value = false;
    }
  }

  Future<bool> patchCandidates(int batchId, List<DetectedItemCandidateModel> candidates) async {
    try {
      await _ds.patchCandidates(
        batchId,
        candidates.map((c) => c.toPatchEntry()).toList(),
      );
      return true;
    } catch (e) {
      Get.snackbar('Wardrobe', e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  void clearPendingReview() {
    pendingReviewBatch.value = null;
  }

  Future<void> toggleFavourite(WardrobeItemApiModel item) async {
    final idx = categoryItems.indexWhere((i) => i.id == item.id);
    if (idx == -1) return;
    final newVal = !item.isFavourite;
    categoryItems[idx] = item.copyWith(isFavourite: newVal); // optimistic
    try {
      final updated = await _ds.patchItem(item.id, isFavourite: newVal);
      categoryItems[idx] = updated;
    } catch (e) {
      categoryItems[idx] = item; // revert
      Get.snackbar('Wardrobe', e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> renameItem(WardrobeItemApiModel item, String newName) async {
    try {
      final updated = await _ds.patchItem(item.id, name: newName);
      final idx = categoryItems.indexWhere((i) => i.id == item.id);
      if (idx != -1) categoryItems[idx] = updated;
    } catch (e) {
      Get.snackbar('Wardrobe', e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> deleteItem(int itemId) async {
    try {
      await _ds.deleteItem(itemId);
      categoryItems.removeWhere((i) => i.id == itemId);
      await loadCategorySummary();
    } catch (e) {
      Get.snackbar('Wardrobe', e.toString().replaceAll('Exception: ', ''));
    }
  }
}
