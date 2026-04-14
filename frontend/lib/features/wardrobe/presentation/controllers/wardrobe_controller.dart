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

  /// All unique style tags across loaded items, sorted alphabetically.
  List<String> get availableStyleTags {
    final tags = <String>{};
    for (final item in categoryItems) {
      tags.addAll(item.styleTags);
    }
    return tags.toList()..sort();
  }

  /// Items filtered by [selectedStyleTag]. Returns all items when no filter set.
  List<WardrobeItemApiModel> get filteredCategoryItems {
    final tag = selectedStyleTag.value;
    if (tag.isEmpty) return categoryItems;
    return categoryItems.where((item) => item.styleTags.contains(tag)).toList();
  }

  void clearStyleTagFilter() => selectedStyleTag.value = '';

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
    selectedStyleTag.value = ''; // reset filter on category change
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
}
