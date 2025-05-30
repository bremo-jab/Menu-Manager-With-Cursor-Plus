import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RestaurantInfoController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final isLoading = false.obs;
  final isPhoneVerifying = false.obs; // حالة تحميل التحقق من رقم الهاتف
  final nameError = false.obs;
  final phoneError = false.obs;
  final verificationId = ''.obs;
  final isPhoneVerified = false.obs;
  final nameErrorMessage = ''.obs;
  final phoneErrorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRestaurantInfo();
    saveLoginInfo();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // تنسيق رقم الهاتف
  String formatPhoneNumber(String phone) {
    // إزالة جميع الأحرف غير الرقمية
    String numbersOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    // إزالة الصفر من البداية إذا كان موجوداً
    if (numbersOnly.startsWith('0')) {
      numbersOnly = numbersOnly.substring(1);
    }

    return numbersOnly;
  }

  // التحقق من صحة رقم الهاتف
  bool isValidPhoneNumber(String phone) {
    // إزالة جميع الأحرف غير الرقمية
    String numbersOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    // إزالة الصفر من البداية إذا كان موجوداً
    if (numbersOnly.startsWith('0')) {
      numbersOnly = numbersOnly.substring(1);
    }

    // التحقق من أن طول الرقم صحيح (9 أرقام)
    return numbersOnly.length == 9;
  }

  Future<void> verifyPhoneNumber() async {
    try {
      // التحقق من صحة رقم الهاتف
      if (!isValidPhoneNumber(phoneController.text)) {
        phoneError.value = true;
        phoneErrorMessage.value = 'يرجى إدخال رقم هاتف صحيح';
        return;
      }

      isPhoneVerifying.value = true;
      phoneError.value = false;
      phoneErrorMessage.value = '';

      // تنسيق رقم الهاتف
      String formattedPhone = formatPhoneNumber(phoneController.text);
      phoneController.text = formattedPhone;

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+970$formattedPhone',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.currentUser
              ?.linkWithCredential(credential);
          isPhoneVerified.value = true;
          isPhoneVerifying.value = false;
        },
        verificationFailed: (FirebaseAuthException e) {
          phoneError.value = true;
          phoneErrorMessage.value = 'فشل التحقق من رقم الهاتف: ${e.message}';
          isPhoneVerifying.value = false;
        },
        codeSent: (String vId, int? resendToken) {
          verificationId.value = vId;
          Get.dialog(
            AlertDialog(
              title: const Text('أدخل رمز التحقق'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'أدخل الرمز المرسل إلى هاتفك',
                    ),
                    onChanged: (value) {
                      if (value.length == 6) {
                        verifyOTP(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ).then((_) {
            if (!isPhoneVerified.value) {
              isPhoneVerifying.value = false;
            }
          });
        },
        codeAutoRetrievalTimeout: (String vId) {
          verificationId.value = vId;
          isPhoneVerifying.value = false;
        },
      );
    } catch (e) {
      phoneError.value = true;
      phoneErrorMessage.value = 'حدث خطأ أثناء التحقق من رقم الهاتف';
      isPhoneVerifying.value = false;
    }
  }

  Future<void> verifyOTP(String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );

      await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
      isPhoneVerified.value = true;
      isPhoneVerifying.value = false;
      Get.back(); // إغلاق نافذة إدخال الرمز
    } catch (e) {
      phoneError.value = true;
      phoneErrorMessage.value = 'فشل التحقق من رمز OTP';
      isPhoneVerifying.value = false;
    }
  }

  Future<void> saveLoginInfo() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      final deviceInfo = "${androidInfo.manufacturer} ${androidInfo.model}";
      final osVersion = androidInfo.version.release;
      final deviceId = androidInfo.id;

      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;

      final now = DateTime.now();
      final formatter = DateFormat('yyyy-MM-dd_HH-mm-ss');
      final docId = formatter.format(now);

      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(uid)
          .collection('logins')
          .doc(docId)
          .set({
        'deviceInfo': deviceInfo,
        'osVersion': osVersion,
        'deviceId': deviceId,
        'appVersion': appVersion,
        'loginTime': now.toUtc(),
      });

      print("✅ تم حفظ معلومات تسجيل الدخول بنجاح");
    } catch (e) {
      print("❌ خطأ أثناء حفظ معلومات تسجيل الدخول: $e");
    }
  }

  Future<void> loadRestaurantInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
      }
    } catch (e) {
      print('Error loading restaurant info: $e');
    }
  }

  Future<void> saveRestaurantInfo() async {
    try {
      bool hasError = false;

      // التحقق من اسم المطعم
      if (nameController.text.isEmpty) {
        nameError.value = true;
        nameErrorMessage.value = 'يرجى إدخال اسم المطعم';
        hasError = true;
      } else {
        nameError.value = false;
        nameErrorMessage.value = '';
      }

      // التحقق من رقم الهاتف
      if (!isPhoneVerified.value) {
        phoneError.value = true;
        phoneErrorMessage.value = 'يجب التحقق من رقم الهاتف أولاً';
        hasError = true;
      } else {
        phoneError.value = false;
        phoneErrorMessage.value = '';
      }

      if (hasError) {
        return;
      }

      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(
          'خطأ',
          'لم يتم العثور على المستخدم',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // حفظ معلومات المطعم
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user.uid)
          .set({
        'name': nameController.text,
        'phone': phoneController.text,
        'isProfileComplete': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ تم حفظ معلومات المطعم بنجاح');

      // الانتقال إلى صفحة الداشبورد
      await Future.delayed(
          const Duration(milliseconds: 500)); // إضافة تأخير قصير
      await Get.offAllNamed('/dashboard', predicate: (route) => false);
    } catch (e) {
      print('❌ خطأ أثناء حفظ معلومات المطعم: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حفظ المعلومات',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
