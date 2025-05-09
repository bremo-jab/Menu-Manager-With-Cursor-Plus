import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';

class PhoneVerificationWidget extends StatefulWidget {
  final TextEditingController phoneController;

  const PhoneVerificationWidget({
    super.key,
    required this.phoneController,
  });

  @override
  State<PhoneVerificationWidget> createState() =>
      _PhoneVerificationWidgetState();
}

class _PhoneVerificationWidgetState extends State<PhoneVerificationWidget> {
  final otpController = TextEditingController();
  bool showOtpField = false;
  bool isVerified = false;
  bool isVerifying = false;
  String? verificationId;

  bool isValidPalestinianPhoneNumber(String phone) {
    if (phone.isEmpty) return false;
    if (phone.length != 9) return false;
    if (!phone.startsWith('5')) return false;
    return true;
  }

  Future<void> verifyPhone() async {
    final rawPhone = widget.phoneController.text.trim();
    if (!isValidPalestinianPhoneNumber(rawPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('الرجاء إدخال رقم هاتف فلسطيني صحيح يتكون من 9 أرقام')),
      );
      return;
    }
    final phone = '+970$rawPhone';

    setState(() {
      isVerifying = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            isVerifying = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل التحقق: ${e.message}')),
          );
        },
        codeSent: (String verId, int? resendToken) {
          setState(() {
            verificationId = verId;
            showOtpField = true;
            isVerifying = false;
          });
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
      );
    } catch (e) {
      setState(() {
        isVerifying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  Future<void> verifyOtp() async {
    if (verificationId == null) return;

    setState(() {
      isVerifying = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpController.text.trim(),
      );
      await _signInWithCredential(credential);
    } catch (e) {
      setState(() {
        isVerifying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كود التحقق غير صحيح')),
      );
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      await FirebaseAuth.instance.currentUser!.reload();
      final controller = Get.find<RestaurantController>();
      controller.isPhoneVerified.value = true;
      setState(() {
        isVerified = true;
        isVerifying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم التحقق من الرقم بنجاح')),
      );
    } catch (e) {
      setState(() {
        isVerifying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل التحقق من الرقم')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 56,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '+970',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: widget.phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 9,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  hintText: '5XXXXXXXX',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: isVerifying ? null : verifyPhone,
              child: isVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('تحقق من الرقم'),
            ),
            if (showOtpField) const SizedBox(width: 12),
            if (showOtpField)
              Expanded(
                child: TextField(
                  controller: otpController,
                  decoration: const InputDecoration(
                    labelText: 'رمز التحقق',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  style: const TextStyle(fontSize: 16),
                  keyboardType: TextInputType.number,
                ),
              ),
          ],
        ),
        if (isVerified)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '✅ تم التحقق من الرقم بنجاح',
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }
}
