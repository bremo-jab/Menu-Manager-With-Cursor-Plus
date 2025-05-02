import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_manager/app/data/models/order_model.dart';

class StatisticsService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  RxInt todayOrdersCount = 0.obs;
  RxInt pendingOrdersCount = 0.obs;
  RxInt confirmedOrdersCount = 0.obs;
  RxInt rejectedOrdersCount = 0.obs;
  RxDouble todayTotalAmount = 0.0.obs;
  RxDouble monthTotalAmount = 0.0.obs;
  RxBool isLoading = false.obs;

  Future<void> loadTodayStatistics(String restaurantId) async {
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
          .get();

      final orders =
          snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();

      todayOrdersCount.value = orders.length;
      todayTotalAmount.value =
          orders.fold(0, (sum, order) => sum + order.totalAmount);
      pendingOrdersCount.value =
          orders.where((order) => order.status == 'pending').length;
      confirmedOrdersCount.value =
          orders.where((order) => order.status == 'confirmed').length;
      rejectedOrdersCount.value =
          orders.where((order) => order.status == 'rejected').length;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب إحصائيات اليوم',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMonthStatistics(String restaurantId) async {
    try {
      isLoading.value = true;
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final snapshot = await _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
          .where('createdAt', isLessThan: endOfMonth)
          .get();

      final orders =
          snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();

      monthTotalAmount.value =
          orders.fold(0, (sum, order) => sum + order.totalAmount);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب إحصائيات الشهر',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
