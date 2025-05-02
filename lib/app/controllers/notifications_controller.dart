import 'package:get/get.dart';
import 'package:menu_manager/app/services/notification_service.dart';

class NotificationsController extends GetxController {
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final notifications = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _notificationService.initialize();
  }

  void addNotification(String notification) {
    notifications.add(notification);
  }
}
