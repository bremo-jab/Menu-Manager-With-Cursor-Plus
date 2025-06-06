import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../views/google_restaurant_info_view.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final isLoading = false.obs;
  final phoneNumber = ''.obs;
  final verificationId = ''.obs;

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Get.snackbar('تم الإلغاء', 'لم يتم تسجيل الدخول');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // التوجيه إلى صفحة إدخال معلومات المطعم الخاصة بـ Google
      Get.offAll(() => const GoogleRestaurantInfoView());
    } catch (e) {
      Get.snackbar('خطأ في تسجيل الدخول', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithPhone(
      String phoneNumber, Function(String) onCodeSent) async {
    if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }
    if (phoneNumber.length != 9 ||
        !RegExp(r'^[5][0-9]{8}$').hasMatch(phoneNumber)) {
      return;
    }

    isLoading.value = true;
    await _auth.verifyPhoneNumber(
      phoneNumber: '+970$phoneNumber',
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        Get.snackbar('فشل التحقق', e.message ?? '');
        isLoading.value = false;
      },
      codeSent: (verificationId, _) {
        onCodeSent(verificationId);
        isLoading.value = false;
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<bool> verifyPhoneAndSignIn(
      String verificationId, String smsCode) async {
    isLoading.value = true;
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String formatPhoneNumber(String phone) {
    phone = phone.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }
    return '+970$phone';
  }

  bool isValidPhoneNumber(String phone) {
    final cleaned = phone.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('0')) {
      return cleaned.length == 10 && cleaned.startsWith('05');
    }
    return cleaned.length == 9 && cleaned.startsWith('5');
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
