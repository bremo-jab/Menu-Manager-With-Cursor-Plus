import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CitySelectorField extends StatelessWidget {
  final TextEditingController controller;
  final RxString? selectedCity;
  final List<String> cityList;

  const CitySelectorField({
    super.key,
    required this.controller,
    required this.selectedCity,
    required this.cityList,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return cityList.where((city) => city.contains(textEditingValue.text));
      },
      onSelected: (value) {
        selectedCity?.value = value;
        controller.text = value;
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'المدينة',
            hintText: 'اختر مدينة',
            prefixIcon: const Icon(Icons.location_city),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء اختيار المدينة';
            }
            return null;
          },
          onChanged: (val) {
            controller.text = val;
            selectedCity?.value = val;
          },
          style: GoogleFonts.cairo(),
        );
      },
    );
  }
}
