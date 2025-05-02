import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';
import 'package:menu_manager/app/widgets/custom_text_field.dart';

class RestaurantInfoSection extends StatelessWidget {
  const RestaurantInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RestaurantController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'اسم المطعم',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: controller.nameController,
              label: 'أدخل اسم المطعم',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم المطعم';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'نوع المطعم',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...controller.restaurantTypes.map((type) {
                      return CheckboxListTile(
                        title: Text(
                          type,
                          style: GoogleFonts.cairo(),
                        ),
                        value:
                            controller.selectedRestaurantTypes.contains(type),
                        onChanged: (value) {
                          if (value == true) {
                            controller.selectedRestaurantTypes.add(type);
                          } else {
                            controller.selectedRestaurantTypes.remove(type);
                          }
                        },
                        activeColor: colorScheme.primary,
                        checkColor: colorScheme.onPrimary,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                    if (controller.selectedRestaurantTypes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'الرجاء اختيار نوع واحد على الأقل',
                          style: GoogleFonts.cairo(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                )),
            const SizedBox(height: 16),
            Text(
              'وصف المطعم',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: controller.descriptionController,
              label: 'مثلاً: مأكولات شرقية مع جلسات عائلية',
              maxLines: 3,
              style: GoogleFonts.cairo(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
