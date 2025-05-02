import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_manager/app/data/models/order_model.dart';

class OrdersService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  RxList<OrderModel> orders = <OrderModel>[].obs;
  RxBool isLoading = false.obs;

  Future<void> createOrder(OrderModel order) async {
    try {
      isLoading.value = true;
      await _firestore
          .collection(_collection)
          .doc(order.id)
          .set(order.toJson());
      orders.add(order);
      Get.snackbar(
        'نجاح',
        'تم إنشاء الطلب بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إنشاء الطلب',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrder(OrderModel order) async {
    try {
      isLoading.value = true;
      await _firestore
          .collection(_collection)
          .doc(order.id)
          .update(order.toJson());
      final index = orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        orders[index] = order;
      }
      Get.snackbar(
        'نجاح',
        'تم تحديث الطلب بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديث الطلب',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteOrder(String id) async {
    try {
      isLoading.value = true;
      await _firestore.collection(_collection).doc(id).delete();
      orders.removeWhere((o) => o.id == id);
      Get.snackbar(
        'نجاح',
        'تم حذف الطلب بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حذف الطلب',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOrders(String restaurantId) async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('createdAt', descending: true)
          .get();
      orders.value =
          snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب الطلبات',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTodayOrders(String restaurantId) async {
    try {
      isLoading.value = true;
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('createdAt', isLessThan: endOfDay)
          .orderBy('createdAt', descending: true)
          .get();

      orders.value =
          snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب طلبات اليوم',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPendingOrders(String restaurantId) async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      orders.value =
          snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب الطلبات المعلقة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
