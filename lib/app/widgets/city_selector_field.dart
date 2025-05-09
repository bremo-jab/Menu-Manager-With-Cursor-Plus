import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';

class CitySelectorField extends StatelessWidget {
  final RestaurantController controller;

  const CitySelectorField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المدينة',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            // لا تقم بتعيين قيمة تلقائية للمدينة هنا لعرض hint بشكل صحيح
            return DropdownButtonFormField<String>(
              value: controller.selectedCity.value.isEmpty
                  ? null
                  : controller.selectedCity.value,
              hint: Text('اختر المدينة', style: GoogleFonts.cairo()),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.black),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedCity.value = value;
                  controller.cityController.text = value;
                }
              },
              items: controller.palestinianCities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city, style: GoogleFonts.cairo()),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
