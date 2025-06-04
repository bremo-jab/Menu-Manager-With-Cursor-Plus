// صفحة إدخال معلومات المطعم بعد تسجيل الدخول عبر Google
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleRestaurantInfoView extends StatefulWidget {
  const GoogleRestaurantInfoView({super.key});

  @override
  State<GoogleRestaurantInfoView> createState() =>
      _GoogleRestaurantInfoViewState();
}

class _GoogleRestaurantInfoViewState extends State<GoogleRestaurantInfoView> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final codeController = TextEditingController();

  String verificationId = '';
  bool isCodeSent = false;
  bool isVerifying = false;
  bool isDialogLoading = false;
  String errorText = '';
  String codeErrorMessage = '';
  bool hasCodeError = false;

  void sendOtp() async {
    String rawPhone = phoneController.text.trim();
    if (rawPhone.startsWith('0')) {
      rawPhone = rawPhone.substring(1);
    }
    if (rawPhone.length != 9 || !RegExp(r'^[5][0-9]{8}$').hasMatch(rawPhone)) {
      setState(() => errorText = 'تحقق من صحة رقم الهاتف.');
      return;
    }
    final phone = '+970$rawPhone';
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (_) {},
      verificationFailed: (e) => Get.snackbar('خطأ', e.message ?? 'فشل التحقق'),
      codeSent: (id, _) {
        verificationId = id;
        setState(() => isCodeSent = true);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  void verifyAndLink() async {
    setState(() {
      isVerifying = true;
      isDialogLoading = true;
      hasCodeError = false;
    });
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: codeController.text.trim(),
    );
    try {
      await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
      // حفظ اسم المطعم هنا إلى Firestore إن أردت
      Get.offAllNamed('/dashboard');
    } catch (e) {
      setState(() {
        hasCodeError = true;
        codeErrorMessage = 'رمز التحقق غير صالح أو منتهي';
      });
    } finally {
      setState(() {
        isVerifying = false;
        isDialogLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('معلومات المطعم')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم المطعم')),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Text('+970', style: TextStyle(fontSize: 16)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: '59*******',
                          labelText: 'رقم الهاتف',
                        ),
                      ),
                    ),
                  ],
                ),
                if (errorText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      errorText,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
            if (isCodeSent) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'رمز التحقق'),
                  ),
                  if (hasCodeError) const SizedBox(height: 4),
                  if (hasCodeError)
                    Text(
                      codeErrorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isDialogLoading ? null : verifyAndLink,
                child: isDialogLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('ربط الرقم'),
              ),
            ] else ...[
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: sendOtp, child: const Text('إرسال رمز التحقق')),
            ]
          ],
        ),
      ),
    );
  }
}
