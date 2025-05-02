import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_manager/app/controllers/orders_controller.dart';
import 'package:menu_manager/app/widgets/custom_button.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () => Get.dialog(
              AlertDialog(
                title: const Text('QR Code'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'قم بمسح هذا الكود للطلب من داخل المطعم',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Image.network(
                      controller.qrCodeUrl.value,
                      width: 200,
                      height: 200,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('إغلاق'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.orders.length,
                itemBuilder: (context, index) {
                  final order = controller.orders[index];
                  return Card(
                    child: ExpansionTile(
                      title: Text('طلب #${order.id}'),
                      subtitle: Text(
                        'الحالة: ${order.status}',
                        style: TextStyle(
                          color: order.status == 'pending'
                              ? Colors.orange
                              : order.status == 'confirmed'
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('العميل: ${order.customerName}'),
                              Text('الهاتف: ${order.customerPhone}'),
                              Text('البريد الإلكتروني: ${order.customerEmail}'),
                              const SizedBox(height: 8),
                              const Text(
                                'العناصر:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ...order.items.map(
                                (item) => ListTile(
                                  title: Text(item.name),
                                  subtitle: Text(item.notes ?? ''),
                                  trailing: Text(
                                    '${item.price} ريال × ${item.quantity}',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'المجموع: ${order.totalAmount} ريال',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('طريقة الدفع: ${order.paymentMethod}'),
                              Text('نوع الخدمة: ${order.serviceType}'),
                              if (order.notes != null) ...[
                                const SizedBox(height: 8),
                                Text('ملاحظات: ${order.notes}'),
                              ],
                              const SizedBox(height: 16),
                              if (order.status == 'pending')
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        onPressed: () =>
                                            controller.confirmOrder(order.id),
                                        text: 'تأكيد',
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: CustomButton(
                                        onPressed: () =>
                                            controller.rejectOrder(order.id),
                                        text: 'رفض',
                                        backgroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
