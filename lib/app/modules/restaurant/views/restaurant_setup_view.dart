import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';
import 'package:menu_manager/app/widgets/custom_button.dart';
import 'package:menu_manager/app/widgets/custom_text_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:menu_manager/app/controllers/auth_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantSetupView extends GetView<RestaurantController> {
  const RestaurantSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إعداد المطعم',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => Get.find<AuthController>().signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() => Stepper(
              type: StepperType.vertical,
              currentStep: controller.currentStep.value,
              onStepContinue: () {
                if (controller.currentStep.value < 5) {
                  controller.currentStep.value++;
                }
              },
              onStepCancel: () {
                if (controller.currentStep.value > 0) {
                  controller.currentStep.value--;
                }
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      if (controller.currentStep.value > 0)
                        Expanded(
                          child: CustomButton(
                            onPressed: () => details.onStepCancel?.call(),
                            text: 'السابق',
                            icon: Icons.arrow_back,
                            backgroundColor: Colors.grey[300],
                            textColor: Colors.black87,
                          ),
                        ),
                      if (controller.currentStep.value > 0)
                        const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          onPressed: controller.currentStep.value == 5
                              ? () => controller.saveRestaurant()
                              : () => details.onStepContinue?.call(),
                          text: controller.currentStep.value == 5
                              ? 'حفظ'
                              : 'التالي',
                          icon: controller.currentStep.value == 5
                              ? Icons.save
                              : Icons.arrow_forward,
                          isLoading: controller.isLoading.value,
                          backgroundColor: controller.currentStep.value == 5
                              ? Colors.green
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
              steps: [
                // Step 1: Logo and Images
                Step(
                  title: Text(
                    'الشعار والصور',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
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
                        child: Column(
                          children: [
                            Text(
                              'شعار المطعم',
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Obx(() => GestureDetector(
                                  onTap: controller.pickLogo,
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundColor: Colors.grey[200],
                                    child: controller.logoImage.value != null
                                        ? ClipOval(
                                            child: Image.file(
                                              controller.logoImage.value!,
                                              width: 140,
                                              height: 140,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.add_a_photo,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'صور المطعم',
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'مرر لليمين لعرض باقي الصور',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Obx(() => SizedBox(
                                  height: 120,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        ...controller.images
                                            .asMap()
                                            .entries
                                            .map(
                                              (entry) => Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      width: 120,
                                                      height: 120,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        image: DecorationImage(
                                                          image: FileImage(
                                                              entry.value),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 4,
                                                      right: 4,
                                                      child: GestureDetector(
                                                        onTap: () => controller
                                                            .removeImage(
                                                                entry.key),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.red,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: const Icon(
                                                            Icons.close,
                                                            size: 16,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: GestureDetector(
                                            onTap: controller.pickImages,
                                            child: Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.add_photo_alternate,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  isActive: controller.currentStep.value >= 0,
                ),
                // Step 2: Restaurant Information
                Step(
                  title: Text(
                    'معلومات المطعم',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
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
                        children: [
                          CustomTextField(
                            controller: controller.nameController,
                            label: 'اسم المطعم',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال اسم المطعم';
                              }
                              return null;
                            },
                            style: GoogleFonts.cairo(),
                          ),
                          const Divider(height: 24),
                          CustomTextField(
                            controller: controller.typeController,
                            label: 'نوع المطعم',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال نوع المطعم';
                              }
                              return null;
                            },
                            style: GoogleFonts.cairo(),
                          ),
                          const Divider(height: 24),
                          CustomTextField(
                            controller: controller.descriptionController,
                            label: 'وصف المطعم',
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال وصف المطعم';
                              }
                              return null;
                            },
                            style: GoogleFonts.cairo(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  isActive: controller.currentStep.value >= 1,
                ),
                // Step 3: Location
                Step(
                  title: Text(
                    'الموقع',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
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
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: controller.cityController,
                          label: 'المدينة',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال المدينة';
                            }
                            return null;
                          },
                          style: GoogleFonts.cairo(),
                        ),
                        const Divider(height: 24),
                        CustomTextField(
                          controller: controller.addressController,
                          label: 'العنوان',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال العنوان';
                            }
                            return null;
                          },
                          style: GoogleFonts.cairo(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'الموقع الجغرافي',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: controller.initialPosition,
                                zoom: 15,
                              ),
                              onMapCreated: controller.onMapCreated,
                              onTap: controller.onMapTap,
                              markers: controller.markers,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  isActive: controller.currentStep.value >= 2,
                ),
                // Step 4: Contact Information
                Step(
                  title: Text(
                    'معلومات الاتصال',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
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
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: controller.phoneController,
                          label: 'رقم الهاتف',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم الهاتف';
                            }
                            if (!GetUtils.isPhoneNumber(value)) {
                              return 'الرجاء إدخال رقم هاتف صحيح';
                            }
                            return null;
                          },
                          style: GoogleFonts.cairo(),
                        ),
                        const Divider(height: 24),
                        CustomTextField(
                          controller: controller.emailController,
                          label: 'البريد الإلكتروني',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال البريد الإلكتروني';
                            }
                            if (!GetUtils.isEmail(value)) {
                              return 'الرجاء إدخال بريد إلكتروني صحيح';
                            }
                            return null;
                          },
                          style: GoogleFonts.cairo(),
                        ),
                        const Divider(height: 24),
                        CustomTextField(
                          controller: controller.websiteController,
                          label: 'الموقع الإلكتروني (اختياري)',
                          keyboardType: TextInputType.url,
                          style: GoogleFonts.cairo(),
                        ),
                      ],
                    ),
                  ),
                  isActive: controller.currentStep.value >= 3,
                ),
                // Step 5: Working Hours
                Step(
                  title: Text(
                    'ساعات العمل',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
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
                    child: Column(
                      children: List.generate(7, (index) {
                        final day = controller.weekDays[index];
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    day,
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextField(
                                    controller: controller
                                        .workingHoursControllers[index][0],
                                    label: 'من',
                                    keyboardType: TextInputType.number,
                                    style: GoogleFonts.cairo(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomTextField(
                                    controller: controller
                                        .workingHoursControllers[index][1],
                                    label: 'إلى',
                                    keyboardType: TextInputType.number,
                                    style: GoogleFonts.cairo(),
                                  ),
                                ),
                              ],
                            ),
                            if (index < 6) const Divider(height: 24),
                          ],
                        );
                      }),
                    ),
                  ),
                  isActive: controller.currentStep.value >= 4,
                ),
                // Step 6: Payment and Service Options
                Step(
                  title: Text(
                    'الدفع والخدمة',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طرق الدفع',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...controller.paymentMethods.map((method) {
                          return CheckboxListTile(
                            title: Text(
                              method,
                              style: GoogleFonts.cairo(),
                            ),
                            value: controller.selectedPaymentMethods
                                .contains(method),
                            onChanged: (value) {
                              if (value == true) {
                                controller.selectedPaymentMethods.add(method);
                              } else {
                                controller.selectedPaymentMethods
                                    .remove(method);
                              }
                            },
                          );
                        }),
                        const Divider(height: 24),
                        Text(
                          'خيارات الخدمة',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...controller.serviceOptions.map((option) {
                          return CheckboxListTile(
                            title: Text(
                              option,
                              style: GoogleFonts.cairo(),
                            ),
                            value: controller.selectedServiceOptions
                                .contains(option),
                            onChanged: (value) {
                              if (value == true) {
                                controller.selectedServiceOptions.add(option);
                              } else {
                                controller.selectedServiceOptions
                                    .remove(option);
                              }
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  isActive: controller.currentStep.value >= 5,
                ),
              ],
            )),
      ),
    );
  }
}
