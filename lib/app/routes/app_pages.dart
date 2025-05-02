import 'package:get/get.dart';
import 'package:menu_manager/app/modules/auth/views/login_view.dart';
import 'package:menu_manager/app/modules/auth/bindings/auth_binding.dart';
import 'package:menu_manager/app/modules/restaurant/views/restaurant_setup_view.dart';
import 'package:menu_manager/app/modules/restaurant/bindings/restaurant_binding.dart';
import 'package:menu_manager/app/modules/menu/views/menu_view.dart';
import 'package:menu_manager/app/modules/menu/bindings/menu_binding.dart';
import 'package:menu_manager/app/modules/orders/views/orders_view.dart';
import 'package:menu_manager/app/modules/orders/bindings/orders_binding.dart';
import 'package:menu_manager/app/modules/statistics/views/statistics_view.dart';
import 'package:menu_manager/app/modules/statistics/bindings/statistics_binding.dart';
import 'package:menu_manager/app/modules/settings/views/settings_view.dart';
import 'package:menu_manager/app/modules/settings/bindings/settings_binding.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.RESTAURANT_SETUP,
      page: () => const RestaurantSetupView(),
      binding: RestaurantBinding(),
    ),
    GetPage(
      name: Routes.MENU,
      page: () => const MenuView(),
      binding: MenuBinding(),
    ),
    GetPage(
      name: Routes.ORDERS,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: Routes.STATISTICS,
      page: () => const StatisticsView(),
      binding: StatisticsBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
