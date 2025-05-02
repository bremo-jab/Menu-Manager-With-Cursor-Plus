import 'package:get/get.dart';
import 'package:menu_manager/app/services/statistics_service.dart';
import 'package:menu_manager/app/services/restaurant_service.dart';

class StatisticsController extends GetxController {
  final StatisticsService _statisticsService = Get.find<StatisticsService>();
  final todayOrdersCount = 0.obs;
  final pendingOrdersCount = 0.obs;
  final confirmedOrdersCount = 0.obs;
  final rejectedOrdersCount = 0.obs;
  final todayTotalAmount = 0.0.obs;
  final monthTotalAmount = 0.0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshStatistics();
  }

  Future<void> refreshStatistics() async {
    try {
      isLoading.value = true;
      final restaurantId = Get.find<RestaurantService>().restaurant.value!.id;
      await _statisticsService.loadTodayStatistics(restaurantId);
      await _statisticsService.loadMonthStatistics(restaurantId);

      todayOrdersCount.value = _statisticsService.todayOrdersCount.value;
      pendingOrdersCount.value = _statisticsService.pendingOrdersCount.value;
      confirmedOrdersCount.value =
          _statisticsService.confirmedOrdersCount.value;
      rejectedOrdersCount.value = _statisticsService.rejectedOrdersCount.value;
      todayTotalAmount.value = _statisticsService.todayTotalAmount.value;
      monthTotalAmount.value = _statisticsService.monthTotalAmount.value;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديث الإحصائيات',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
