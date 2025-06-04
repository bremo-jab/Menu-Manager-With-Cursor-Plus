// صفحة إدخال معلومات المطعم بعد تسجيل الدخول باستخدام Google
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleRestaurantInfoView extends StatefulWidget {
  const GoogleRestaurantInfoView({super.key});

  @override
  State<GoogleRestaurantInfoView> createState() =>
      _GoogleRestaurantInfoViewState();
}

class _GoogleRestaurantInfoViewState extends State<GoogleRestaurantInfoView> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  bool isSaving = false;

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
