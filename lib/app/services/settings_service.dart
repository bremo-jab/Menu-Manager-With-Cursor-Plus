import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> updateProfile(String displayName, String phoneNumber) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      // Phone number update requires verification
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await user.updatePhoneNumber(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar(
            'خطأ',
            'فشل التحقق من رقم الهاتف: ${e.message}',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          // Handle SMS code sent
          Get.snackbar(
            'تم',
            'تم إرسال رمز التحقق',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
        },
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    Get.offAllNamed('/login');
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
      Get.offAllNamed('/login');
    }
  }
}
