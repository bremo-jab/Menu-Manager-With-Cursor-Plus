import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_manager/app/data/models/menu_item_model.dart';
import 'package:menu_manager/app/data/models/menu_category_model.dart';

class MenuService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _categoriesCollection = 'menu_categories';
  final String _itemsCollection = 'menu_items';

  RxList<MenuCategoryModel> categories = <MenuCategoryModel>[].obs;
  RxList<MenuItemModel> items = <MenuItemModel>[].obs;
  RxBool isLoading = false.obs;

  Future<void> createCategory(MenuCategoryModel category) async {
    try {
      isLoading.value = true;
      await _firestore
          .collection(_categoriesCollection)
          .doc(category.id)
          .set(category.toJson());
      categories.add(category);
      Get.snackbar(
        'نجاح',
        'تم إنشاء الفئة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إنشاء الفئة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(MenuCategoryModel category) async {
    try {
      isLoading.value = true;
      await _firestore
          .collection(_categoriesCollection)
          .doc(category.id)
          .update(category.toJson());
      final index = categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        categories[index] = category;
      }
      Get.snackbar(
        'نجاح',
        'تم تحديث الفئة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديث الفئة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      isLoading.value = true;
      await _firestore.collection(_categoriesCollection).doc(id).delete();
      categories.removeWhere((c) => c.id == id);
      Get.snackbar(
        'نجاح',
        'تم حذف الفئة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حذف الفئة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createMenuItem(MenuItemModel item) async {
    try {
      isLoading.value = true;
      await _firestore
          .collection(_itemsCollection)
          .doc(item.id)
          .set(item.toJson());
      items.add(item);
      Get.snackbar(
        'نجاح',
        'تم إنشاء العنصر بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إنشاء العنصر',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMenuItem(MenuItemModel item) async {
    try {
      isLoading.value = true;
      await _firestore
          .collection(_itemsCollection)
          .doc(item.id)
          .update(item.toJson());
      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        items[index] = item;
      }
      Get.snackbar(
        'نجاح',
        'تم تحديث العنصر بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
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

  Future<void> deleteMenuItem(String id) async {
    try {
      isLoading.value = true;
      await _firestore.collection(_itemsCollection).doc(id).delete();
      items.removeWhere((i) => i.id == id);
      Get.snackbar(
        'نجاح',
        'تم حذف العنصر بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حذف العنصر',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories(String restaurantId) async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore
          .collection(_categoriesCollection)
          .where('restaurantId', isEqualTo: restaurantId)
          .get();
      categories.value = snapshot.docs
          .map((doc) => MenuCategoryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب الفئات',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadItems(String restaurantId) async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore
          .collection(_itemsCollection)
          .where('restaurantId', isEqualTo: restaurantId)
          .get();
      items.value = snapshot.docs
          .map((doc) => MenuItemModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب العناصر',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
