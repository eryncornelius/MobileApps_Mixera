import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/models/address_model.dart';
import '../../data/models/address_suggestion_model.dart';
import '../../data/models/notification_settings_model.dart';
import '../../data/models/profile_model.dart';

class ProfileController extends GetxController {
  final ProfileRemoteDatasource _remote = ProfileRemoteDatasource();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final profile = Rxn<ProfileModel>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  final addresses = <AddressModel>[].obs;
  final isLoadingAddresses = false.obs;
  final isSavingAddress = false.obs;

  final recipientNameController = TextEditingController();
  final addressPhoneController = TextEditingController();
  final streetAddressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();

  final selectedAddressLabel = 'home'.obs;
  final isPrimaryAddress = false.obs;
  final addressSuggestions = <AddressSuggestionModel>[].obs;
  final isSearchingAddress = false.obs;
  Timer? _addressSearchDebounce;

  final isChangingPassword = false.obs;

  final notificationSettings = Rxn<NotificationSettingsModel>();
  final isLoadingNotificationSettings = false.obs;
  final isSavingNotificationSettings = false.obs;
  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchAddresses();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final result = await _remote.getProfile();
      profile.value = result;

      usernameController.text = result.username;
      emailController.text = result.email;
      phoneController.text = result.phoneNumber ?? '';
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveProfile() async {
    final username = usernameController.text.trim();
    final phone = phoneController.text.trim();

    if (username.isEmpty) {
      Get.snackbar('Error', 'Username tidak boleh kosong.');
      return false;
    }

    isSaving.value = true;
    try {
      final updated = await _remote.updateProfile(
        username: username,
        phoneNumber: phone.isEmpty ? null : phone,
      );

      profile.value = updated;
      usernameController.text = updated.username;
      emailController.text = updated.email;
      phoneController.text = updated.phoneNumber ?? '';

      Get.snackbar('Success', 'Profile berhasil diperbarui.');
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isSaving.value = false;
    }
  }
  Future<bool> changePassword() async {
  final currentPassword = currentPasswordController.text.trim();
  final newPassword = newPasswordController.text.trim();
  final confirmPassword = confirmNewPasswordController.text.trim();

  if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
    Get.snackbar('Error', 'Semua field password harus diisi.');
    return false;
  }

  if (newPassword != confirmPassword) {
    Get.snackbar('Error', 'Konfirmasi password tidak sama.');
    return false;
  }

  isChangingPassword.value = true;
  try {
    await _remote.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    currentPasswordController.clear();
    newPasswordController.clear();
    confirmNewPasswordController.clear();

    Get.snackbar('Success', 'Password berhasil diubah.');
    return true;
  } catch (e) {
    Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    return false;
  } finally {
    isChangingPassword.value = false;
  }
}
Future<void> fetchAddresses() async {
  isLoadingAddresses.value = true;
  try {
    final result = await _remote.getAddresses();
    addresses.assignAll(result);
  } catch (e) {
    Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
  } finally {
    isLoadingAddresses.value = false;
  }
}

void fillAddressForm(AddressModel address) {
  recipientNameController.text = address.recipientName;
  addressPhoneController.text = address.phoneNumber;
  streetAddressController.text = address.streetAddress;
  cityController.text = address.city;
  stateController.text = address.state;
  postalCodeController.text = address.postalCode;
  selectedAddressLabel.value = address.label;
  isPrimaryAddress.value = address.isPrimary;
  clearAddressSuggestions();
}

void clearAddressForm() {
  recipientNameController.clear();
  addressPhoneController.clear();
  streetAddressController.clear();
  cityController.clear();
  stateController.clear();
  postalCodeController.clear();
  selectedAddressLabel.value = 'home';
  isPrimaryAddress.value = false;
  clearAddressSuggestions();
}

void onAddressQueryChanged(String query) {
  _addressSearchDebounce?.cancel();
  final q = query.trim();
  if (q.length < 3) {
    clearAddressSuggestions();
    return;
  }
  isSearchingAddress.value = true;
  _addressSearchDebounce = Timer(const Duration(milliseconds: 350), () async {
    final suggestions = await _remote.searchAddressSuggestions(q);
    addressSuggestions.assignAll(suggestions);
    isSearchingAddress.value = false;
  });
}

void applyAddressSuggestion(AddressSuggestionModel picked) {
  streetAddressController.text = picked.streetAddress.isNotEmpty
      ? picked.streetAddress
      : picked.fullAddress;
  if (picked.city.isNotEmpty) cityController.text = picked.city;
  if (picked.state.isNotEmpty) stateController.text = picked.state;
  if (picked.postalCode.isNotEmpty) postalCodeController.text = picked.postalCode;
  clearAddressSuggestions();
}

void clearAddressSuggestions() {
  _addressSearchDebounce?.cancel();
  isSearchingAddress.value = false;
  addressSuggestions.clear();
}

Future<bool> createAddress() async {
  if (recipientNameController.text.trim().isEmpty ||
      addressPhoneController.text.trim().isEmpty ||
      streetAddressController.text.trim().isEmpty ||
      cityController.text.trim().isEmpty ||
      stateController.text.trim().isEmpty ||
      postalCodeController.text.trim().isEmpty) {
    Get.snackbar('Error', 'Semua field alamat harus diisi.');
    return false;
  }

  isSavingAddress.value = true;
  try {
    final created = await _remote.createAddress(
      label: selectedAddressLabel.value,
      recipientName: recipientNameController.text.trim(),
      phoneNumber: addressPhoneController.text.trim(),
      streetAddress: streetAddressController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      postalCode: postalCodeController.text.trim(),
      isPrimary: isPrimaryAddress.value,
    );

    final index = addresses.indexWhere((e) => e.id == created.id);
    if (index >= 0) {
      addresses[index] = created;
    } else {
      addresses.insert(0, created);
    }

    await fetchAddresses();
    clearAddressForm();
    Get.snackbar('Success', 'Alamat berhasil ditambahkan.');
    return true;
  } catch (e) {
    Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    return false;
  } finally {
    isSavingAddress.value = false;
  }
}

Future<bool> updateAddress(int id) async {
  if (recipientNameController.text.trim().isEmpty ||
      addressPhoneController.text.trim().isEmpty ||
      streetAddressController.text.trim().isEmpty ||
      cityController.text.trim().isEmpty ||
      stateController.text.trim().isEmpty ||
      postalCodeController.text.trim().isEmpty) {
    Get.snackbar('Error', 'Semua field alamat harus diisi.');
    return false;
  }

  isSavingAddress.value = true;
  try {
    await _remote.updateAddress(
      id: id,
      label: selectedAddressLabel.value,
      recipientName: recipientNameController.text.trim(),
      phoneNumber: addressPhoneController.text.trim(),
      streetAddress: streetAddressController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      postalCode: postalCodeController.text.trim(),
      isPrimary: isPrimaryAddress.value,
    );

    await fetchAddresses();
    clearAddressForm();
    Get.snackbar('Success', 'Alamat berhasil diperbarui.');
    return true;
  } catch (e) {
    Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    return false;
  } finally {
    isSavingAddress.value = false;
  }
}

Future<void> deleteAddress(int id) async {
  try {
    await _remote.deleteAddress(id);
    await fetchAddresses();
    Get.snackbar('Success', 'Alamat berhasil dihapus.');
  } catch (e) {
    Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
  }
}

Future<void> setPrimaryAddress(AddressModel address) async {
  try {
    await _remote.updateAddress(
      id: address.id,
      label: address.label,
      recipientName: address.recipientName,
      phoneNumber: address.phoneNumber,
      streetAddress: address.streetAddress,
      city: address.city,
      state: address.state,
      postalCode: address.postalCode,
      isPrimary: true,
    );
    await fetchAddresses();
    Get.snackbar('Success', 'Alamat utama berhasil diubah.');
  } catch (e) {
    Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
  }
}

Future<void> fetchNotificationSettings() async {
  isLoadingNotificationSettings.value = true;
  try {
    final result = await _remote.getNotificationSettings();
    notificationSettings.value = result;
  } catch (e) {
    Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
  } finally {
    isLoadingNotificationSettings.value = false;
  }
}

Future<bool> saveNotificationSettings({
  required bool orderUpdates,
  required bool promotions,
  required bool securityAlerts,
  required bool dailyReminders,
}) async {
  isSavingNotificationSettings.value = true;
  try {
    final updated = await _remote.updateNotificationSettings(
      orderUpdates: orderUpdates,
      promotions: promotions,
      securityAlerts: securityAlerts,
      dailyReminders: dailyReminders,
    );
    notificationSettings.value = updated;
    Get.snackbar('Success', 'Pengaturan notifikasi disimpan.');
    return true;
  } catch (e) {
    Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    return false;
  } finally {
    isSavingNotificationSettings.value = false;
  }
}

  @override
  void onClose() {
    _addressSearchDebounce?.cancel();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    recipientNameController.dispose();
    addressPhoneController.dispose();
    streetAddressController.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    super.onClose();
  }
}
