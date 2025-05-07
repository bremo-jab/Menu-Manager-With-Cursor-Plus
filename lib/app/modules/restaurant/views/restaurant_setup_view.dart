import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';
import 'package:menu_manager/app/widgets/custom_button.dart';
import 'package:menu_manager/app/widgets/custom_text_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:menu_manager/app/controllers/auth_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menu_manager/utils/snackbar_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:menu_manager/app/widgets/phone_verification_widget.dart';

class RestaurantSetupView extends GetView<RestaurantController> {
  const RestaurantSetupView({super.key});

  bool isValidUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.');
  }

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
                if (controller.currentStep.value == 0) {
                  if (!controller.formKey.currentState!.validate()) return;

                  if (controller.selectedRestaurantTypes.isEmpty) {
                    showErrorSnackbar(
                        'الرجاء اختيار نوع واحد على الأقل من أنواع المطعم');
                    return;
                  }

                  if (controller.logoImage.value == null) {
                    showErrorSnackbar('الرجاء اختيار صورة شعار المطعم');
                    return;
                  }

                  if (controller.images.isEmpty) {
                    showErrorSnackbar(
                        'الرجاء اختيار صورة واحدة على الأقل من صور المطعم');
                    return;
                  }
                }

                if (controller.currentStep.value == 3) {
                  if (!controller.socialLinksFormKey.currentState!.validate())
                    return;
                }

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
                          onPressed: () {
                            if (controller.currentStep.value == 3) {
                              if (!controller.socialLinksFormKey.currentState!
                                  .validate()) {
                                return;
                              }
                            }

                            if (controller.currentStep.value == 0) {
                              if (controller.logoImage.value == null) {
                                showErrorSnackbar(
                                    'الرجاء اختيار صورة شعار المطعم');
                                return;
                              }

                              if (controller.images.isEmpty) {
                                showErrorSnackbar(
                                    'الرجاء اختيار صورة واحدة على الأقل من صور المطعم');
                                return;
                              }
                            }

                            if (controller.currentStep.value == 1) {
                              final name =
                                  controller.nameController.text.trim();

                              if (name.isEmpty) {
                                showErrorSnackbar('الرجاء إدخال اسم المطعم');
                                return;
                              }

                              if (controller.selectedRestaurantTypes.isEmpty) {
                                showErrorSnackbar(
                                    'الرجاء اختيار نوع واحد على الأقل من أنواع المطعم');
                                return;
                              }
                            }

                            if (controller.currentStep.value == 5) {
                              controller.saveRestaurant();
                            } else {
                              controller.currentStep.value++;
                            }
                          },
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
                            GestureDetector(
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
                            ),
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
                            SizedBox(
                              height: 120,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ...controller.images.asMap().entries.map(
                                          (entry) => Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: 120,
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
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
                                                        .removeImage(entry.key),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
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
                                      padding: const EdgeInsets.only(left: 8),
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
                            ),
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
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('نوع المطعم',
                                  style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              ...controller.restaurantTypes.map((type) {
                                return CheckboxListTile(
                                  title: Text(type, style: GoogleFonts.cairo()),
                                  value: controller.selectedRestaurantTypes
                                      .contains(type),
                                  onChanged: (value) {
                                    if (value == true) {
                                      controller.selectedRestaurantTypes
                                          .add(type);
                                    } else {
                                      controller.selectedRestaurantTypes
                                          .remove(type);
                                    }
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                          CustomTextField(
                            controller: controller.descriptionController,
                            label: 'وصف المطعم (اختياري)',
                            maxLines: 3,
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
                        // City Dropdown
                        DropdownButtonFormField<String>(
                          value: controller.palestinianCities
                                  .contains(controller.selectedCity.value)
                              ? controller.selectedCity.value
                              : null,
                          decoration: InputDecoration(
                            labelText: 'المدينة',
                            labelStyle: GoogleFonts.cairo(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: controller.palestinianCities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(
                                city,
                                style: GoogleFonts.cairo(),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedCity.value = value;
                              controller.cityController.text = value;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء اختيار المدينة';
                            }
                            return null;
                          },
                        ),
                        const Divider(height: 24),
                        // Address Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: controller.addressController,
                              decoration: InputDecoration(
                                labelText: 'العنوان',
                                labelStyle: GoogleFonts.cairo(),
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              style: GoogleFonts.cairo(),
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              onChanged: (_) =>
                                  controller.isAddressManuallyEdited = true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الرجاء إدخال العنوان';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'يرجى التأكد من دقة العنوان، بدون ذكر الدولة',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
                          height: 300,
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
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: controller.initialPosition,
                                    zoom: 15,
                                  ),
                                  onMapCreated:
                                      (GoogleMapController mapController) {
                                    controller.mapController = mapController;
                                    controller.getCurrentLocation();
                                  },
                                  onTap: controller.onMapTap,
                                  onCameraMove: controller.onCameraMove,
                                  markers: controller.markers,
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: false,
                                  liteModeEnabled: false,
                                  gestureRecognizers:
                                      <Factory<OneSequenceGestureRecognizer>>{
                                    Factory<OneSequenceGestureRecognizer>(
                                        () => EagerGestureRecognizer()),
                                  }.toSet(),
                                ),
                              ),
                              Obx(() => controller.isMapMoved.value
                                  ? Positioned(
                                      bottom: 16,
                                      right: 16,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            onTap:
                                                controller.getCurrentLocation,
                                            child: const Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Icon(
                                                Icons.my_location,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink()),
                            ],
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
                    child: Form(
                      key: controller.socialLinksFormKey,
                      child: Column(
                        children: [
                          PhoneVerificationWidget(
                            phoneController: controller.phoneController,
                          ),
                          const Divider(height: 24),
                          TextFormField(
                            controller: controller.emailController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              labelStyle: GoogleFonts.cairo(),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            style: GoogleFonts.cairo(),
                          ),
                          const SizedBox(height: 4),
                          Obx(() => CheckboxListTile(
                                title: Text(
                                  'أوافق على تلقي التحديثات والأخبار عبر البريد الإلكتروني',
                                  style: GoogleFonts.cairo(fontSize: 14),
                                ),
                                value: controller.wantsEmailUpdates.value,
                                onChanged: (val) => controller
                                    .wantsEmailUpdates.value = val ?? false,
                              )),
                          const Divider(height: 24),
                          CustomTextField(
                            controller: controller.facebookController,
                            label: 'رابط فيسبوك (اختياري)',
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  !isValidUrl(value)) {
                                return 'الرجاء إدخال رابط صحيح يبدأ بـ http أو https';
                              }
                              return null;
                            },
                            style: GoogleFonts.cairo(),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: controller.instagramController,
                            label: 'رابط إنستغرام (اختياري)',
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  !isValidUrl(value)) {
                                return 'الرجاء إدخال رابط صحيح يبدأ بـ http أو https';
                              }
                              return null;
                            },
                            style: GoogleFonts.cairo(),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: controller.twitterController,
                            label: 'رابط تويتر (اختياري)',
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  !isValidUrl(value)) {
                                return 'الرجاء إدخال رابط صحيح يبدأ بـ http أو https';
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
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  !isValidUrl(value)) {
                                return 'الرجاء إدخال رابط صحيح يبدأ بـ http أو https';
                              }
                              return null;
                            },
                            style: GoogleFonts.cairo(),
                          ),
                        ],
                      ),
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
                        Column(
                          children: controller.paymentMethods.map((method) {
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
                          }).toList(),
                        ),
                        const Divider(height: 24),
                        Text(
                          'خيارات الخدمة',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: controller.serviceOptions.map((option) {
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
                          }).toList(),
                        ),
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
