import 'package:get/get.dart';
import 'package:menu_manager/app/data/models/order_model.dart';
import 'package:menu_manager/app/services/orders_service.dart';
import 'package:menu_manager/app/services/restaurant_service.dart';

class OrdersController extends GetxController {
  final OrdersService _ordersService = Get.find<OrdersService>();
  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final qrCodeUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    generateQRCode();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      await _ordersService
          .loadOrders(Get.find<RestaurantService>().restaurant.value!.id);
      orders.value = _ordersService.orders;
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

  Future<void> generateQRCode() async {
    try {
      final restaurantId = Get.find<RestaurantService>().restaurant.value!.id;
      // TODO: Implement QR code generation
      qrCodeUrl.value = 'https://example.com/qr/$restaurantId';
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إنشاء QR code',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> confirmOrder(String orderId) async {
    try {
      isLoading.value = true;
      final order = orders.firstWhere((order) => order.id == orderId);
      final updatedOrder = OrderModel(
        id: order.id,
        restaurantId: order.restaurantId,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        customerEmail: order.customerEmail,
        items: order.items,
        totalAmount: order.totalAmount,
        status: 'confirmed',
        paymentMethod: order.paymentMethod,
        serviceType: order.serviceType,
        notes: order.notes,
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
      );

      await _ordersService.updateOrder(updatedOrder);
      Get.snackbar(
        'نجاح',
        'تم تأكيد الطلب بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تأكيد الطلب',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectOrder(String orderId) async {
    try {
      isLoading.value = true;
      final order = orders.firstWhere((order) => order.id == orderId);
      final updatedOrder = OrderModel(
        id: order.id,
        restaurantId: order.restaurantId,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        customerEmail: order.customerEmail,
        items: order.items,
        totalAmount: order.totalAmount,
        status: 'rejected',
        paymentMethod: order.paymentMethod,
        serviceType: order.serviceType,
        notes: order.notes,
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
      );

      await _ordersService.updateOrder(updatedOrder);
      Get.snackbar(
        'نجاح',
        'تم رفض الطلب بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء رفض الطلب',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
