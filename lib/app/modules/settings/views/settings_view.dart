import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_manager/app/controllers/settings_controller.dart';
import 'package:menu_manager/app/widgets/custom_button.dart';
import 'package:menu_manager/app/widgets/custom_text_field.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الملف الشخصي',
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
                      CustomTextField(
                        controller: controller.nameController,
                        label: 'الاسم',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الاسم';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: controller.phoneController,
                        label: 'رقم الهاتف',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        onPressed: controller.updateProfile,
                        text: 'حفظ',
                        isLoading: controller.isLoading.value,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'حول التطبيق',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تطبيق إدارة المطعم',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'الإصدار: 1.0.0',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'تطبيق إدارة المطعم هو تطبيق متكامل لإدارة المطاعم، يتيح لك إدارة القائمة والطلبات والإحصائيات بسهولة.',
                        style: TextStyle(
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        onPressed: () {
                          // TODO: Implement support link
                        },
                        text: 'الدعم الفني',
                        icon: Icons.support,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: controller.signOut,
                text: 'تسجيل الخروج',
                icon: Icons.logout,
                backgroundColor: Colors.red,
                isLoading: controller.isLoading.value,
              ),
              const SizedBox(height: 16),
              CustomButton(
                onPressed: () => Get.dialog(
                  AlertDialog(
                    title: const Text('حذف الحساب'),
                    content: const Text(
                      'هل أنت متأكد من حذف الحساب؟ لا يمكن التراجع عن هذا الإجراء.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.deleteAccount();
                        },
                        child: const Text(
                          'حذف',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                text: 'حذف الحساب',
                icon: Icons.delete_forever,
                backgroundColor: Colors.red,
                isLoading: controller.isLoading.value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
