import 'package:get/get.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';

class RestaurantBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RestaurantController>(() => RestaurantController());
  }
}
