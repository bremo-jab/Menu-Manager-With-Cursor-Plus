import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  void _showPhoneNumberDialog(
      BuildContext context, LoginController controller) {
    final phoneController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('أدخل رقم الهاتف'),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'رقم الهاتف',
            hintText: 'مثال: 597351035',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.isNotEmpty) {
                Get.back();
                controller.sendOtpToPhoneNumber(phoneController.text);
              }
            },
            child: const Text('إرسال رمز التحقق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A237E).withOpacity(0.9),
              const Color(0xFF3949AB).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: isSmallScreen ? 20 : 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: isSmallScreen ? 20 : 60),
                      // شعار المطعم
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          size: isSmallScreen ? 50 : 60,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 40),

                      // عنوان التطبيق
                      Text(
                        'مرحباً بك',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 28 : 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'سجل دخولك لإدارة مطعمك بكل سهولة',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isSmallScreen ? 30 : 60),

                      // Loading Animation or Login Buttons
                      Obx(() => controller.isLoading.value
                          ? Center(
                              child: Lottie.asset(
                                'assets/animations/login-loading.json',
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                                repeat: true,
                                animate: true,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Lottie animation error: $error');
                                  print('Stack trace: $stackTrace');
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'خطأ في تحميل الرسوم المتحركة',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                          : Column(
                              children: [
                                // زر تسجيل الدخول باستخدام جوجل
                                Container(
                                  width: double.infinity,
                                  height: isSmallScreen ? 50 : 55,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: controller.signInWithGoogle,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black87,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      elevation: 0,
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.g_mobiledata,
                                          size: isSmallScreen ? 28 : 32,
                                          color: const Color(0xFF4285F4),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'تسجيل الدخول باستخدام Google',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 14 : 16,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF757575),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 15 : 20),

                                // خط فاصل
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(
                                        'أو',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmallScreen ? 15 : 20),

                                // زر تسجيل الدخول باستخدام رقم الهاتف
                                Container(
                                  width: double.infinity,
                                  height: isSmallScreen ? 50 : 55,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: OutlinedButton(
                                    onPressed: () => _showPhoneNumberDialog(
                                        context, controller),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.phone_android,
                                          color: Colors.white,
                                          size: isSmallScreen ? 20 : 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'تسجيل الدخول باستخدام رقم الهاتف',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 14 : 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      SizedBox(height: isSmallScreen ? 20 : 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
