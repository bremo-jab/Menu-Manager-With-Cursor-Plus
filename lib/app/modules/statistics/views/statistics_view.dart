import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_manager/app/controllers/statistics_controller.dart';
import 'package:menu_manager/app/controllers/auth_controller.dart';
import 'package:menu_manager/app/widgets/custom_button.dart';

class StatisticsView extends GetView<StatisticsController> {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => Get.find<AuthController>().signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إحصائيات اليوم',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              'عدد الطلبات',
                              controller.todayOrdersCount.toString(),
                              Icons.shopping_cart,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              'المجموع',
                              '${controller.todayTotalAmount} ريال',
                              Icons.attach_money,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              'قيد الانتظار',
                              controller.pendingOrdersCount.toString(),
                              Icons.hourglass_empty,
                              color: Colors.orange,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              'مؤكدة',
                              controller.confirmedOrdersCount.toString(),
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              'مرفوضة',
                              controller.rejectedOrdersCount.toString(),
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'إحصائيات الشهر',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildStatItem(
                    'إجمالي المبيعات',
                    '${controller.monthTotalAmount} ريال',
                    Icons.bar_chart,
                    isLarge: true,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: controller.refreshStatistics,
                text: 'تحديث',
                icon: Icons.refresh,
                isLoading: controller.isLoading.value,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon, {
    Color? color,
    bool isLarge = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: isLarge ? 48 : 32,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isLarge ? 16 : 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 24 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
