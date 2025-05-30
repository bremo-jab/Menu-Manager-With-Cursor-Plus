import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/restaurant_info_controller.dart';
import '../widgets/custom_app_bar.dart';

class RestaurantInfoView extends StatelessWidget {
  const RestaurantInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RestaurantInfoController());

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'معلومات المطعم',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // بطاقة اسم المطعم
                      Obx(() => Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: controller.nameError.value
                                  ? const BorderSide(
                                      color: Colors.red, width: 2)
                                  : BorderSide.none,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'اسم المطعم',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: controller.nameController,
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        controller.nameError.value = false;
                                        controller.nameErrorMessage.value = '';
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'أدخل اسم المطعم',
                                      hintTextDirection: TextDirection.rtl,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Colors.blue),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                  Obx(() => controller.nameError.value
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            controller.nameErrorMessage.value,
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        )
                                      : const SizedBox.shrink()),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 24),
                      // بطاقة رقم الهاتف
                      Obx(() => Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: controller.phoneError.value
                                  ? const BorderSide(
                                      color: Colors.red, width: 2)
                                  : BorderSide.none,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Obx(() => controller.isPhoneVerified.value
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color:
                                                        Colors.green.shade700,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'تم التحقق',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.green.shade700,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox.shrink()),
                                      Text(
                                        'رقم الهاتف',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: controller.phoneController,
                                    keyboardType: TextInputType.phone,
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        controller.phoneError.value = false;
                                        controller.phoneErrorMessage.value = '';
                                      }
                                    },
                                    decoration: InputDecoration(
                                      prefixText: '+970 ',
                                      prefixStyle: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 16,
                                      ),
                                      hintText: 'أدخل رقم الهاتف',
                                      hintTextDirection: TextDirection.rtl,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Colors.blue),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                  Obx(() => controller.phoneError.value
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            controller.phoneErrorMessage.value,
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        )
                                      : const SizedBox.shrink()),
                                  const SizedBox(height: 16),
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Obx(() => ElevatedButton(
                                            onPressed: controller
                                                        .isPhoneVerifying
                                                        .value ||
                                                    controller
                                                        .isPhoneVerified.value
                                                ? null
                                                : () => controller
                                                    .verifyPhoneNumber(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 2,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.phone_android,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'التحقق من رقم الهاتف',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                      Obx(() => controller
                                              .isPhoneVerifying.value
                                          ? Container(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink()),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
            // زر الحفظ في أسفل الشاشة
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.saveRestaurantInfo(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'حفظ المعلومات',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
