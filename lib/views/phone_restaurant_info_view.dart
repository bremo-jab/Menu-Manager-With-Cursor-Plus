// صفحة إدخال معلومات المطعم بعد تسجيل الدخول برقم الهاتف
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneRestaurantInfoView extends StatefulWidget {
  const PhoneRestaurantInfoView({super.key});

  @override
  State<PhoneRestaurantInfoView> createState() =>
      _PhoneRestaurantInfoViewState();
}

class _PhoneRestaurantInfoViewState extends State<PhoneRestaurantInfoView> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  bool isSaving = false;
  bool isLinking = false;

  // دالة حفظ معلومات المطعم في Firestore
  Future<void> _saveRestaurantInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('خطأ', 'لم يتم العثور على المستخدم');
        return;
      }

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

  // دالة ربط حساب Google
  Future<void> linkWithGoogle() async {
    setState(() => isLinking = true);

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      setState(() => isLinking = false);
      return;
    }

    final googleAuth = await googleUser.authentication;
    final googleCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final email = googleUser.email;
    final signInMethods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

    if (signInMethods.contains('google.com')) {
      // الحساب مرتبط مسبقًا، نسجل الخروج من الحساب الحالي
      final currentPhoneCredential =
          await FirebaseAuth.instance.currentUser?.getIdToken();
      await FirebaseAuth.instance.signOut();

      // تسجيل الدخول باستخدام Google
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(googleCredential);

      // بعد تسجيل الدخول بنجاح، ربط رقم الهاتف بالحساب الحالي
      // لاحظ أن عملية ربط الهاتف تحتاج إلى تنفيذ Firebase Phone Auth مسبقًا وجلب verificationId و smsCode
      // هذا مجرد تمهيد، ويجب أن تكون البيانات موجودة
      final verificationId = ""; // ضع verificationId هنا
      final smsCode = ""; // ضع smsCode هنا

      final phoneCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await userCredential.user?.linkWithCredential(phoneCredential);
    } else {
      // الحساب غير موجود مسبقًا، يمكن ربط Google مباشرة
      await FirebaseAuth.instance.currentUser
          ?.linkWithCredential(googleCredential);
    }

    setState(() => isLinking = false);
  }

  // دالة تسجيل الخروج
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الخروج',
        backgroundColor: Colors.red.shade100,
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
            onPressed: _signOut,
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
                          SizedBox(height: spacing * 1.5),
                          // زر ربط حساب Google
                          Container(
                            width: double.infinity,
                            height: isSmallScreen ? 60 : 70,
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
                            child: OutlinedButton.icon(
                              icon: Icon(
                                Icons.link,
                                size: isSmallScreen ? 24 : 28,
                                color: const Color(0xFF6A1B9A),
                              ),
                              label: Text(
                                'ربط حساب Google',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  color: const Color(0xFF6A1B9A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Color(0xFF6A1B9A)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLinking ? null : linkWithGoogle,
                            ),
                          ),
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
