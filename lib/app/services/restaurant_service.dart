import 'dart:io';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_manager/app/data/models/restaurant_model.dart';
import 'package:menu_manager/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:menu_manager/app/controllers/auth_controller.dart';

class RestaurantService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthController _authController = Get.find<AuthController>();
  final String _collection = 'restaurants';

  Rx<RestaurantModel?> restaurant = Rx<RestaurantModel?>(null);
  RxBool isLoading = false.obs;

  Future<void> createRestaurant(
    Map<String, dynamic> restaurantData,
    File? logoFile,
    List<File> images,
  ) async {
    try {
      isLoading.value = true;
      // Upload logo
      String? logoUrl;
      if (logoFile != null) {
        final logoRef = _storage.ref().child(
            'restaurants/logos/${DateTime.now().millisecondsSinceEpoch}');
        await logoRef.putFile(logoFile);
        logoUrl = await logoRef.getDownloadURL();
      }

      // Upload images
      final List<String> imageUrls = [];
      for (var image in images) {
        final imageRef = _storage.ref().child(
            'restaurants/images/${DateTime.now().millisecondsSinceEpoch}');
        await imageRef.putFile(image);
        final imageUrl = await imageRef.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // Add logo and image URLs to restaurant data
      restaurantData['logoUrl'] = logoUrl;
      restaurantData['imageUrls'] = imageUrls;

      // Create restaurant document
      final restaurantRef =
          await _firestore.collection(_collection).add(restaurantData);
      final restaurantId = restaurantRef.id;

      // Update user document with restaurant ID
      final user = _authController.user.value;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'restaurantId': restaurantId,
        });
      }

      Get.snackbar(
        'نجاح',
        'تم إنشاء المطعم بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إنشاء المطعم',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRestaurant(
    String restaurantId,
    Map<String, dynamic> data,
  ) async {
    try {
      isLoading.value = true;
      await _firestore.collection(_collection).doc(restaurantId).update(data);
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
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<RestaurantModel?> getRestaurant(String restaurantId) async {
    try {
      isLoading.value = true;
      final doc =
          await _firestore.collection(_collection).doc(restaurantId).get();
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

  Future<void> deleteRestaurant(String restaurantId) async {
    try {
      isLoading.value = true;
      await _firestore.collection(_collection).doc(restaurantId).delete();
      restaurant.value = null;
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حذف المطعم',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
