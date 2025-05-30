import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الخروج',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
