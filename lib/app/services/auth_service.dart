import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:menu_manager/app/routes/app_pages.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  Rx<User?> user = Rx<User?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('تم إلغاء تسجيل الدخول بواسطة Google');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        Get.offAllNamed(Routes.RESTAURANT_SETUP);
      }
      return userCredential;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الدخول باستخدام Google',
        snackPosition: SnackPosition.BOTTOM,
      );
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    try {
      isLoading.value = true;
      final LoginResult result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) {
        throw Exception('تم إلغاء تسجيل الدخول بواسطة Facebook');
      }

      final AccessToken accessToken = result.accessToken!;
      final OAuthCredential credential = FacebookAuthProvider.credential(
        accessToken.token,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        Get.offAllNamed(Routes.RESTAURANT_SETUP);
      }
      return userCredential;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الدخول باستخدام Facebook',
        snackPosition: SnackPosition.BOTTOM,
      );
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الخروج',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
