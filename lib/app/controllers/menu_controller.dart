import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:menu_manager/app/data/models/menu_category_model.dart';
import 'package:menu_manager/app/data/models/menu_item_model.dart';
import 'package:menu_manager/app/services/menu_service.dart';
import 'package:menu_manager/app/services/restaurant_service.dart';
import 'package:uuid/uuid.dart';

class MenuController extends GetxController {
  final MenuService _menuService = Get.find<MenuService>();
  final RestaurantService _restaurantService = Get.find<RestaurantService>();
  final categoryNameController = TextEditingController();
  final categoryDescriptionController = TextEditingController();
  final itemNameController = TextEditingController();
  final itemDescriptionController = TextEditingController();
  final itemPriceController = TextEditingController();

  final categories = <MenuCategoryModel>[].obs;
  final items = <MenuItemModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadItems();
  }

  @override
  void onClose() {
    categoryNameController.dispose();
    categoryDescriptionController.dispose();
    itemNameController.dispose();
    itemDescriptionController.dispose();
    itemPriceController.dispose();
    super.onClose();
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      await _menuService
          .loadCategories(_restaurantService.restaurant.value!.id);
      categories.value = _menuService.categories;
    } catch (e) {
      Future.delayed(Duration.zero, () {
        Get.snackbar(
          'خطأ',
          'حدث خطأ أثناء جلب الفئات',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadItems() async {
    try {
      isLoading.value = true;
      await _menuService.loadItems(_restaurantService.restaurant.value!.id);
      items.value = _menuService.items;
    } catch (e) {
      Future.delayed(Duration.zero, () {
        Get.snackbar(
          'خطأ',
          'حدث خطأ أثناء جلب العناصر',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory() async {
    if (categoryNameController.text.isEmpty ||
        categoryDescriptionController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء ملء جميع الحقول',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final category = MenuCategoryModel(
        id: const Uuid().v4(),
        restaurantId: _restaurantService.restaurant.value!.id,
        name: categoryNameController.text,
        description: categoryDescriptionController.text,
        order: categories.length,
        imageUrl: '', // Will be updated after upload
      );

      await _menuService.createCategory(category);
      categoryNameController.clear();
      categoryDescriptionController.clear();
      Get.back();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إضافة الفئة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addItem(String categoryId) async {
    if (itemNameController.text.isEmpty ||
        itemDescriptionController.text.isEmpty ||
        itemPriceController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء ملء جميع الحقول',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final item = MenuItemModel(
        id: const Uuid().v4(),
        restaurantId: _restaurantService.restaurant.value!.id,
        categoryId: categoryId,
        name: itemNameController.text,
        description: itemDescriptionController.text,
        price: double.parse(itemPriceController.text),
        imageUrl: '', // Will be updated after upload
        isAvailable: true,
        order: items.where((item) => item.categoryId == categoryId).length,
      );

      await _menuService.createMenuItem(item);
      itemNameController.clear();
      itemDescriptionController.clear();
      itemPriceController.clear();
      Get.back();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إضافة العنصر',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateItem(String itemId) async {
    if (itemNameController.text.isEmpty ||
        itemDescriptionController.text.isEmpty ||
        itemPriceController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء ملء جميع الحقول',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final item = items.firstWhere((item) => item.id == itemId);
      final updatedItem = MenuItemModel(
        id: item.id,
        restaurantId: item.restaurantId,
        categoryId: item.categoryId,
        name: itemNameController.text,
        description: itemDescriptionController.text,
        price: double.parse(itemPriceController.text),
        imageUrl: item.imageUrl,
        isAvailable: item.isAvailable,
        order: item.order,
      );

      await _menuService.updateMenuItem(updatedItem);
      itemNameController.clear();
      itemDescriptionController.clear();
      itemPriceController.clear();
      Get.back();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديث العنصر',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
