import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_manager/app/data/models/restaurant_model.dart';
import 'package:menu_manager/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RestaurantService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'restaurants';

  Rx<RestaurantModel?> restaurant = Rx<RestaurantModel?>(null);
  RxBool isLoading = false.obs;

  Future<void> createRestaurant(RestaurantModel restaurant) async {
    try {
      isLoading.value = true;
      await _firestore
          .collection(_collection)
          .doc(restaurant.id)
          .set(restaurant.toJson());
      this.restaurant.value = restaurant;

      // ربط معرف المطعم مع المستخدم
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'restaurantId': restaurant.id,
        });

        Get.snackbar(
          'نجاح',
          'تم إنشاء بيانات المطعم وربطه بحسابك بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      Get.offAllNamed(Routes.MENU);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إنشاء بيانات المطعم',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRestaurant(RestaurantModel restaurant) async {
    try {
      isLoading.value = true;
      await _firestore
          .collection(_collection)
          .doc(restaurant.id)
          .update(restaurant.toJson());
      this.restaurant.value = restaurant;
      Get.snackbar(
        'نجاح',
        'تم تحديث بيانات المطعم بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديث بيانات المطعم',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<RestaurantModel?> getRestaurant(String id) async {
    try {
      isLoading.value = true;
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        restaurant.value = RestaurantModel.fromJson(doc.data()!);
        return restaurant.value;
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب بيانات المطعم',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRestaurant(String id) async {
    try {
      isLoading.value = true;
      await _firestore.collection(_collection).doc(id).delete();
      restaurant.value = null;
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حذف بيانات المطعم',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
