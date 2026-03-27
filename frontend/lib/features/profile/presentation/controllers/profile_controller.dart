import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/models/profile_model.dart';

class ProfileController extends GetxController {
  final ProfileRemoteDatasource _remote = ProfileRemoteDatasource();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final profile = Rxn<ProfileModel>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
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

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
