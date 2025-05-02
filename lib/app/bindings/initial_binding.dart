import 'package:get/get.dart';
import 'package:menu_manager/app/controllers/auth_controller.dart';
import 'package:menu_manager/app/services/auth_service.dart';
import 'package:menu_manager/app/services/restaurant_service.dart';
import 'package:menu_manager/app/services/menu_service.dart';
import 'package:menu_manager/app/services/orders_service.dart';
import 'package:menu_manager/app/services/statistics_service.dart';
import 'package:menu_manager/app/services/settings_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(RestaurantService(), permanent: true);
    Get.put(MenuService(), permanent: true);
    Get.put(OrdersService(), permanent: true);
    Get.put(StatisticsService(), permanent: true);
    Get.put(SettingsService(), permanent: true);
  }
}
