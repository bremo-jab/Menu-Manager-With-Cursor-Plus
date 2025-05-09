import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantNameField extends StatelessWidget {
  final TextEditingController controller;

  const RestaurantNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: 60,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.business),
        hintText: 'اسم المطعم (مثال: مطعم الشيف عبود)',
        labelText: 'اسم المطعم',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'الرجاء إدخال اسم المطعم';
        }
        return null;
      },
      style: GoogleFonts.cairo(),
    );
  }
}
