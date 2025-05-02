import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menu_manager/app/routes/app_pages.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:menu_manager/app/models/user_model.dart';
import 'package:menu_manager/app/models/device_info_model.dart';
import 'package:uuid/uuid.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
  final isLoading = false.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> _showProviderDialog(String email, String provider) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تنبيه'),
        content: Text(
          'البريد الإلكتروني $email مسجل مسبقاً باستخدام $provider. هل تريد تسجيل الدخول باستخدام $provider؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('نعم'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (provider == 'Google') {
        await signInWithGoogle();
      } else if (provider == 'Facebook') {
        await signInWithFacebook();
      }
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceId = '';
    String deviceType = '';
    String operatingSystem = '';

    try {
      if (GetPlatform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id ?? '';
        deviceType = '${androidInfo.brand} ${androidInfo.model}';
        operatingSystem = 'Android ${androidInfo.version.release}';
      } else if (GetPlatform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
        deviceType = iosInfo.model ?? '';
        operatingSystem = '${iosInfo.systemName} ${iosInfo.systemVersion}';
      }
    } catch (e) {
      print('Error getting device info: $e');
    }

    return {
      'deviceId': deviceId,
      'deviceType': deviceType,
      'operatingSystem': operatingSystem,
    };
  }

  Future<void> _handleUserData(User? user, String provider) async {
    if (user != null) {
      try {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(user.email);
        final userDoc = await userRef.get();

        if (!userDoc.exists) {
          final userData = UserModel(
            uid: user.uid,
            displayName: user.displayName ?? '',
            email: user.email ?? '',
            provider: provider,
            createdAt: DateTime.now(),
          ).toMap();

          await userRef.set(userData);
        }

        final deviceInfo = await _getDeviceInfo();
        final deviceData = DeviceInfoModel(
          deviceId: deviceInfo['deviceId'],
          deviceType: deviceInfo['deviceType'],
          operatingSystem: deviceInfo['operatingSystem'],
          loginTime: DateTime.now(),
          userId: user.uid,
        ).toMap();

        final timestamp = DateTime.now().toIso8601String();
        final uuid = const Uuid().v4();
        final docId = "$timestamp-$uuid";

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .collection('devices')
            .doc(docId)
            .set(deviceData);

        await saveLoginStatus(user.uid);
        await checkUserStateAndRedirect();
      } catch (e) {
        print('Error handling user data: $e');
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final email = googleUser.email;

      // التحقق من وجود حساب بنفس البريد في Firestore
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (userDoc.exists) {
        final existingProvider = userDoc.data()?['provider'] ?? '';

        if (existingProvider != 'Google') {
          await _showProviderDialog(email, existingProvider);
          isLoading.value = false;
          return;
        }
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _handleUserData(userCredential.user, 'Google');

      // تخزين حالة تسجيل الدخول
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('خطأ', 'فشل تسجيل الدخول');
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      isLoading.value = true;

      final loginResult = await FacebookAuth.instance.login();
      if (loginResult.status != LoginStatus.success) {
        isLoading.value = false;
        return;
      }

      final accessToken = loginResult.accessToken;
      final userData = await FacebookAuth.instance.getUserData();
      final email = userData['email'];

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (userDoc.exists) {
        final existingProvider = userDoc.data()?['provider'] ?? '';

        if (existingProvider != 'Facebook') {
          await _showProviderDialog(email, existingProvider);
          isLoading.value = false;
          return;
        }
      }

      final credential = FacebookAuthProvider.credential(accessToken!.token);
      final userCredential = await _auth.signInWithCredential(credential);
      await _handleUserData(userCredential.user, 'Facebook');

      // تخزين حالة تسجيل الدخول
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('خطأ', 'فشل تسجيل الدخول');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('isLoggedIn'); // حذف حالة تسجيل الدخول
      isLoading.value = false;
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء تسجيل الخروج');
    }
  }

  Future<void> saveLoginStatus(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', uid);
  }

  Future<void> checkUserStateAndRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData['restaurantId'] != null) {
          Get.offAllNamed(Routes.MENU);
        } else {
          Get.offAllNamed(Routes.RESTAURANT_SETUP);
        }
      } else {
        Get.offAllNamed(Routes.RESTAURANT_SETUP);
      }
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
