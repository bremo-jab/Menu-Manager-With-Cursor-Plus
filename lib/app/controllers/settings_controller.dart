import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:menu_manager/app/services/settings_service.dart';

class SettingsController extends GetxController {
  final SettingsService _settingsService = Get.find<SettingsService>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final user = _settingsService.getCurrentUser();
    if (user != null) {
      nameController.text = user.displayName ?? '';
      phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> updateProfile() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء ملء جميع الحقول',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _settingsService.updateProfile(
        nameController.text,
        phoneController.text,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديث الملف الشخصي',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _settingsService.signOut();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الخروج',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      await _settingsService.deleteAccount();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حذف الحساب',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
