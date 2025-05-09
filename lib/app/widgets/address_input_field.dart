import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onRestore;

  const AddressInputField({
    super.key,
    required this.controller,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          maxLength: 200,
          decoration: InputDecoration(
            labelText: 'العنوان',
            hintText: 'شارع اليرموك، بجانب البنك الوطني...',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          maxLines: null,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الرجاء إدخال العنوان';
            }
            return null;
          },
          style: GoogleFonts.cairo(),
        ),
        TextButton.icon(
          onPressed: onRestore,
          icon: const Icon(Icons.refresh),
          label: Text(
            'استعادة العنوان من الخريطة',
            style: GoogleFonts.cairo(),
          ),
        ),
      ],
    );
  }
}
