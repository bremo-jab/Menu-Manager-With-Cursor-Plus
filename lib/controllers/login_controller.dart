import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../views/restaurant_info_view.dart';
import '../controllers/restaurant_info_controller.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final isLoading = false.obs;
  final phoneNumber = ''.obs;
  final verificationId = ''.obs;

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await Get.put(RestaurantInfoController()).saveLoginInfo();

        // Check if user exists in Firestore
        final userDoc =
            await _firestore.collection('restaurants').doc(user.uid).get();

        if (!userDoc.exists) {
          // New user, navigate to restaurant info
          Get.off(() => const RestaurantInfoView());
        } else {
          // Existing user, check if profile is complete
          final userData = userDoc.data() as Map<String, dynamic>;
          if (userData['isProfileComplete'] == true) {
            Get.offAllNamed('/dashboard');
          } else {
            Get.off(() => const RestaurantInfoView());
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الدخول باستخدام Google',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtpToPhoneNumber(String rawPhone) async {
    isLoading.value = true;
    try {
      final fullPhone = '+970$rawPhone'; // الرقم الكامل مع الكود الدولي
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhone,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-retrieval
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar("خطأ", "فشل التحقق: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId.value = verificationId;
          Get.snackbar("تم الإرسال", "تم إرسال رمز التحقق بنجاح");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId.value = verificationId;
        },
      );
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ أثناء إرسال رمز التحقق");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String otp) async {
    try {
      isLoading.value = true;

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // تسجيل معلومات الدخول
        await logLoginInfo('+970${phoneNumber.value}');

        // Check if user exists in Firestore
        final userDoc =
            await _firestore.collection('restaurants').doc(user.uid).get();

        if (!userDoc.exists) {
          // New user, navigate to restaurant info
          Get.off(() => const RestaurantInfoView());
        } else {
          // Existing user, check if profile is complete
          final userData = userDoc.data() as Map<String, dynamic>;
          if (userData['isProfileComplete'] == true) {
            Get.offAllNamed('/dashboard');
          } else {
            Get.off(() => const RestaurantInfoView());
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل التحقق من رمز OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logLoginInfo(String phoneNumber) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('logins').doc(uid).collection('sessions').add({
      'phoneNumber': phoneNumber,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
