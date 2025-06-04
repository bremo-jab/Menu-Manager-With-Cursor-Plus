// صفحة إدخال معلومات المطعم بعد تسجيل الدخول باستخدام Google
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:menu_manager/views/login_view.dart';

class GoogleRestaurantInfoView extends StatefulWidget {
  const GoogleRestaurantInfoView({super.key});

  @override
  State<GoogleRestaurantInfoView> createState() =>
      _GoogleRestaurantInfoViewState();
}

class _GoogleRestaurantInfoViewState extends State<GoogleRestaurantInfoView> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final codeController = TextEditingController();

  bool isSaving = false;
  bool isLinking = false;
  bool isCodeSent = false;
  String verificationId = '';
  String errorText = '';
  String codeErrorMessage = '';
  bool hasCodeError = false;

  // دالة حفظ معلومات المطعم في Firestore
  Future<void> _saveRestaurantInfo() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('خطأ', 'لم يتم العثور على المستخدم');
      return;
    }

    if (user.phoneNumber == null) {
      Get.snackbar('تنبيه', 'يرجى ربط رقم الهاتف قبل حفظ البيانات');
      return;
    }

    setState(() => isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user.uid)
          .set({
        'name': nameController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isProfileComplete': true,
      });

      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حفظ المعلومات',
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  // دالة إرسال رمز التحقق
  Future<void> _sendVerificationCode() async {
    String rawPhone = phoneController.text.trim();
    if (rawPhone.startsWith('0')) {
      rawPhone = rawPhone.substring(1);
    }
    if (rawPhone.length != 9 || !RegExp(r'^[5][0-9]{8}$').hasMatch(rawPhone)) {
      setState(() => errorText = 'تحقق من صحة رقم الهاتف.');
      return;
    }

    setState(() {
      isLinking = true;
      errorText = '';
    });

    try {
      final phone = '+970$rawPhone';
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (_) {},
        verificationFailed: (e) {
          setState(() {
            errorText = e.message ?? 'فشل التحقق';
            isLinking = false;
          });
        },
        codeSent: (id, _) {
          setState(() {
            verificationId = id;
            isCodeSent = true;
            isLinking = false;
          });
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      setState(() {
        errorText = 'حدث خطأ أثناء إرسال رمز التحقق';
        isLinking = false;
      });
    }
  }

  // دالة التحقق من الرمز وربط رقم الهاتف
  Future<void> _verifyAndLinkPhone() async {
    if (codeController.text.trim().isEmpty) {
      setState(() {
        hasCodeError = true;
        codeErrorMessage = 'الرجاء إدخال رمز التحقق';
      });
      return;
    }

    setState(() {
      isLinking = true;
      hasCodeError = false;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: codeController.text.trim(),
      );

      // محاولة ربط رقم الهاتف
      try {
        await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
        Get.snackbar('نجاح', 'تم ربط رقم الهاتف بنجاح');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked' ||
            e.code == 'credential-already-in-use') {
          Get.dialog(
            AlertDialog(
              title: const Text('⚠️ لا يمكن ربط هذا الحساب'),
              content: const Text(
                'رقم الهاتف أو البريد الإلكتروني الذي تحاول ربطه مرتبط مسبقًا بحساب مختلف.\n'
                'الرجاء التواصل مع مطوّر التطبيق على الرقم: 0597351035.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('حسنًا'),
                ),
              ],
            ),
          );
        } else if (e.code == 'invalid-verification-code') {
          setState(() {
            hasCodeError = true;
            codeErrorMessage = 'رمز التحقق غير صحيح';
          });
        } else if (e.code == 'invalid-verification-id') {
          setState(() {
            hasCodeError = true;
            codeErrorMessage = 'انتهت صلاحية رمز التحقق، يرجى طلب رمز جديد';
          });
        } else {
          Get.snackbar(
            'خطأ',
            'حدث خطأ: ${e.message}',
            backgroundColor: Colors.red.shade100,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: $e',
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      setState(() => isLinking = false);
    }
  }

  // دالة تسجيل الخروج
  Future<void> _logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint("خطأ أثناء تسجيل الخروج من Google: $e");
    }

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("خطأ أثناء تسجيل الخروج من Firebase: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء تسجيل الخروج من Firebase'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      Get.offAll(() => LoginView());
    } catch (e) {
      debugPrint("خطأ أثناء الانتقال لصفحة تسجيل الدخول: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء إعادة التوجيه'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final padding = size.width * 0.05;
    final spacing = isSmallScreen ? 20.0 : 30.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'معلومات المطعم',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6A1B9A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF6A1B9A)),
            onPressed: _logout,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6A1B9A),
              const Color(0xFF4527A0),
              const Color(0xFF283593),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: spacing),
                          // حقل إدخال اسم المطعم
                          TextFormField(
                            controller: nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'اسم المطعم',
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              hintText: 'أدخل اسم المطعم...',
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5)),
                              prefixIcon: const Icon(Icons.restaurant,
                                  color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isSmallScreen ? 12 : 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الرجاء إدخال اسم المطعم';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: spacing),
                          // حقل إدخال رقم الهاتف
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: const Text(
                                  '+970',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'رقم الهاتف',
                                    labelStyle:
                                        const TextStyle(color: Colors.white70),
                                    hintText: '59*******',
                                    hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.5)),
                                    prefixIcon: const Icon(Icons.phone,
                                        color: Colors.white70),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.white30),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          const BorderSide(color: Colors.white),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: isSmallScreen ? 12 : 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (errorText.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              errorText,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (isCodeSent) ...[
                            SizedBox(height: spacing),
                            // حقل إدخال رمز التحقق
                            TextFormField(
                              controller: codeController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'رمز التحقق',
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                hintText: 'أدخل رمز التحقق...',
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.5)),
                                prefixIcon: const Icon(Icons.lock_outline,
                                    color: Colors.white70),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white30),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: isSmallScreen ? 12 : 16,
                                ),
                              ),
                            ),
                            if (hasCodeError) ...[
                              const SizedBox(height: 8),
                              Text(
                                codeErrorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            SizedBox(height: spacing),
                            // زر التحقق من الرمز
                            Container(
                              width: double.infinity,
                              height: isSmallScreen ? 50 : 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed:
                                    isLinking ? null : _verifyAndLinkPhone,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6A1B9A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLinking
                                    ? SizedBox(
                                        width: isSmallScreen ? 24 : 28,
                                        height: isSmallScreen ? 24 : 28,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'ربط رقم الهاتف',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ] else ...[
                            SizedBox(height: spacing),
                            // زر إرسال رمز التحقق
                            Container(
                              width: double.infinity,
                              height: isSmallScreen ? 50 : 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed:
                                    isLinking ? null : _sendVerificationCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6A1B9A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLinking
                                    ? SizedBox(
                                        width: isSmallScreen ? 24 : 28,
                                        height: isSmallScreen ? 24 : 28,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'إرسال رمز التحقق',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // زر حفظ المعلومات في الأسفل
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: Border(
                    top: BorderSide(color: Colors.white30),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _saveRestaurantInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 16 : 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? SizedBox(
                            width: isSmallScreen ? 24 : 28,
                            height: isSmallScreen ? 24 : 28,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'حفظ المعلومات',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
