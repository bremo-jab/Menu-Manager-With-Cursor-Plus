import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/login_controller.dart';
import '../views/phone_restaurant_info_view.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final controller = Get.put(LoginController());
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  String verificationId = '';
  bool isCodeSent = false;
  bool hasError = false;
  bool hasCodeError = false;
  String errorMessage = '';
  String codeErrorMessage = '';
  final RxBool isDialogOpen = false.obs;

  void showPhoneLoginDialog(BuildContext context) {
    isDialogOpen.value = true;
    final phoneController = TextEditingController();
    final codeController = TextEditingController();
    bool isCodeSent = false;
    bool hasError = false;
    bool hasCodeError = false;
    String errorMessage = '';
    String codeErrorMessage = '';
    String verificationId = '';
    bool isDialogLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          print('🟢 تم تحميل الديالوج المعدل');
          return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            title: const Text(
              'تسجيل الدخول برقم الهاتف',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.left,
                          textDirection: TextDirection.ltr,
                          decoration: const InputDecoration(
                            hintText: '05*******',
                            labelText: 'رقم الهاتف',
                            hintTextDirection: TextDirection.ltr,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text('+970', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  if (hasError) const SizedBox(height: 8),
                  if (hasError)
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  if (isCodeSent)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        TextField(
                          controller: codeController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'رمز التحقق'),
                        ),
                        if (hasCodeError) const SizedBox(height: 4),
                        if (hasCodeError)
                          Text(
                            codeErrorMessage,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isDialogLoading
                    ? null
                    : () {
                        setState(() => isDialogLoading = true);
                        if (!isCodeSent) {
                          String phone = phoneController.text.trim();
                          if (phone.startsWith('0')) phone = phone.substring(1);

                          if (phone.length != 9 ||
                              !RegExp(r'^[5][0-9]{8}$').hasMatch(phone)) {
                            setState(() {
                              hasError = true;
                              errorMessage = 'تحقق من صحة رقم الهاتف.';
                              isDialogLoading = false;
                            });
                            return;
                          }

                          controller.signInWithPhone(phone, (id) {
                            setState(() {
                              verificationId = id;
                              isCodeSent = true;
                              hasError = false;
                              errorMessage = '';
                              isDialogLoading = false;
                            });
                          });
                        } else {
                          controller
                              .verifyPhoneAndSignIn(
                            verificationId,
                            codeController.text.trim(),
                          )
                              .then((success) {
                            setState(() {
                              isDialogLoading = false;
                            });
                            if (success) {
                              Get.offAll(() => const PhoneRestaurantInfoView());
                            } else {
                              setState(() {
                                hasCodeError = true;
                                codeErrorMessage =
                                    'رمز التحقق المدخل غير صحيح. حاول مرة أخرى';
                              });
                            }
                          });
                        }
                      },
                child: isDialogLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(isCodeSent ? 'تسجيل الدخول' : 'إرسال الكود'),
              ),
            ],
          );
        },
      ),
    ).then((_) {
      isDialogOpen.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      Obx(() => controller.isLoading.value &&
                              !isDialogOpen.value
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
                                    onPressed: () =>
                                        showPhoneLoginDialog(context),
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
