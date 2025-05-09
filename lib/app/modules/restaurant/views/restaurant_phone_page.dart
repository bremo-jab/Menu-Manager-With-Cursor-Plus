import 'package:flutter/material.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';
import 'package:get/get.dart';

class RestaurantPhonePage extends StatelessWidget {
  final RestaurantController controller;

  const RestaurantPhonePage({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'رقم الهاتف',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixText: '+970 ',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      suffixIcon: Obx(() {
                        if (controller.isLoading.value) {
                          return const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          );
                        }
                        if (controller.isPhoneVerified.value) {
                          return const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          );
                        }
                        return IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () => controller.sendOTP(),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (!controller.isPhoneVerified.value) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: controller.otpController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'رمز التحقق',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'تم إرسال رمز التحقق إلى رقم هاتفك',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
