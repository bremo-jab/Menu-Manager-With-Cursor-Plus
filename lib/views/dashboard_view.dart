import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_app_bar.dart';

class DashboardController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تسجيل الخروج',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'لوحة التحكم',
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildMenuCard(
            title: 'إدارة القائمة',
            icon: Icons.restaurant_menu,
            onTap: () => Get.toNamed('/menu'),
          ),
          _buildMenuCard(
            title: 'الطلبات',
            icon: Icons.shopping_cart,
            onTap: () => Get.toNamed('/orders'),
          ),
          _buildMenuCard(
            title: 'التقارير',
            icon: Icons.bar_chart,
            onTap: () => Get.toNamed('/reports'),
          ),
          _buildMenuCard(
            title: 'الإعدادات',
            icon: Icons.settings,
            onTap: () => Get.toNamed('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(Get.context!).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
