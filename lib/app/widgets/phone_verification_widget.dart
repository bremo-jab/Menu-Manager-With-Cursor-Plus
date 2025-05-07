import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                '+970',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: widget.phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  labelStyle: GoogleFonts.cairo(),
                  hintText: '5XXXXXXXX',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: GoogleFonts.cairo(),
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
            const SizedBox(width: 12),
            if (showOtpField)
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'أدخل كود OTP',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isVerifying ? null : verifyOtp,
                      child: isVerifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('تأكيد'),
                    ),
                  ],
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
