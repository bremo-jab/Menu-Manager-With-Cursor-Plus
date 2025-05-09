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
import 'package:menu_manager/app/models/working_day_model.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:menu_manager/app/widgets/restaurant_images_section.dart';
import 'package:menu_manager/app/widgets/restaurant_name_field.dart';
import 'package:menu_manager/app/widgets/restaurant_type_selector.dart';
import 'package:menu_manager/app/widgets/city_selector_field.dart';
import 'package:menu_manager/app/widgets/address_input_field.dart';
import 'package:menu_manager/app/widgets/map_location_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:menu_manager/app/modules/restaurant/views/full_map_location_view.dart';

class RestaurantSetupView extends GetView<RestaurantController> {
  const RestaurantSetupView({super.key});

  bool isValidUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.');
  }

  Future<void> moveAppToBackground() async {
    const platform = MethodChannel('com.menu.app/channel');
    try {
      await platform.invokeMethod('moveToBackground');
    } on PlatformException catch (e) {
      print("فشل إرسال التطبيق للخلفية: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await moveAppToBackground();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'إعداد المطعم',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              moveAppToBackground();
            },
          ),
        ),
        body: SizedBox.expand(
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 120),
                child: Obx(() => Stepper(
                      type: StepperType.vertical,
                      currentStep: controller.currentStep.value,
                      onStepContinue: () {},
                      onStepCancel: () {},
                      controlsBuilder: (context, details) =>
                          const SizedBox.shrink(),
                      steps: [
                        Step(
                          title: Text(
                            'الشعار والصور',
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 120),
                            child:
                                RestaurantImagesSection(controller: controller),
                          ),
                          isActive: controller.currentStep.value >= 0,
                        ),
                        Step(
                          title: Text(
                            'المعلومات الأساسية',
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 120),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16.0, bottom: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: controller.nameController,
                                    decoration: InputDecoration(
                                      labelText: 'اسم المطعم',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      labelStyle: const TextStyle(
                                          fontSize: 18, height: 1.8),
                                      prefixIcon: const Icon(Icons.restaurant),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 24),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال اسم المطعم';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          isActive: controller.currentStep.value >= 1,
                        ),
                        Step(
                          title: Text(
                            'نوع المطعم',
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 120),
                            child:
                                RestaurantTypeSelector(controller: controller),
                          ),
                          isActive: controller.currentStep.value >= 2,
                        ),
                        Step(
                          title: Text(
                            'المعلومات الإضافية',
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 120),
                            child: IntrinsicHeight(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 16, bottom: 16),
                                child: Material(
                                  child:
                                      CitySelectorField(controller: controller),
                                ),
                              ),
                            ),
                          ),
                          isActive: controller.currentStep.value >= 3,
                        ),
                        Step(
                          title: Text(
                            'الموقع',
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 120),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'موقع المطعم',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final result = await Get.to(
                                                () => FullMapLocationView(
                                                      controller: controller,
                                                      initialPosition: LatLng(
                                                        controller
                                                            .selectedLatitude
                                                            .value,
                                                        controller
                                                            .selectedLongitude
                                                            .value,
                                                      ),
                                                    ));

                                            if (result != null) {
                                              controller.selectedLatitude
                                                  .value = result['latitude'];
                                              controller.selectedLongitude
                                                  .value = result['longitude'];
                                              controller.addressController
                                                  .text = result['address'];
                                            }
                                          },
                                          icon: const Icon(Icons.map),
                                          label: Text(
                                            'تحديد الموقع من الخريطة',
                                            style: GoogleFonts.cairo(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller:
                                              controller.addressController,
                                          decoration: InputDecoration(
                                            labelText: 'العنوان',
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            labelStyle: const TextStyle(
                                                fontSize: 16, height: 1.8),
                                            prefixIcon:
                                                const Icon(Icons.location_on),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'يرجى التأكد من صحة العنوان وتعديله إن لزم',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Obx(() {
                                          final lat =
                                              controller.selectedLatitude.value;
                                          final lng = controller
                                              .selectedLongitude.value;
                                          return Text(
                                            'إحداثيات الموقع: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isActive: controller.currentStep.value >= 4,
                        ),
                        Step(
                          title: Text(
                            'رقم الهاتف',
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 120),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'رقم الهاتف',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    PhoneVerificationWidget(
                                      phoneController:
                                          controller.phoneController,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          isActive: controller.currentStep.value >= 5,
                        ),
                      ],
                    )),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Obx(() => Row(
                        children: [
                          if (controller.currentStep.value > 0)
                            Expanded(
                              child: CustomButton(
                                onPressed: () {
                                  controller.currentStep.value--;
                                },
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
                                if (controller.currentStep.value == 5 &&
                                    !controller.isPhoneVerified.value) {
                                  Get.snackbar(
                                    'تنبيه',
                                    'يرجى توثيق رقم الهاتف قبل المتابعة',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                goToNextStep();
                              },
                              text: 'التالي',
                              icon: Icons.arrow_forward,
                              isLoading: controller.isLoading.value,
                              backgroundColor: controller.currentStep.value == 5
                                  ? Colors.green
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void goToNextStep() {
    print(
        'logoImage: ${controller.logoImage.value}, images: ${controller.images.length}');
    if (controller.currentStep.value == 0) {
      if (controller.logoImage.value == null || controller.images.isEmpty) {
        showErrorSnackbar(
            'يرجى اختيار صورة الشعار وصورة واحدة على الأقل من صور المطعم قبل المتابعة');
        return;
      }
    }
    if (controller.currentStep.value == 1 &&
        controller.nameController.text.trim().isEmpty) {
      showErrorSnackbar('يرجى إدخال اسم المطعم قبل المتابعة');
      return;
    }
    if (controller.currentStep.value == 2 &&
        controller.selectedRestaurantTypes.isEmpty) {
      showErrorSnackbar('يرجى اختيار نوع واحد من أنواع المطاعم على الأقل');
      return;
    }
    if (controller.currentStep.value == 3 &&
        controller.selectedCity.value.isEmpty) {
      showErrorSnackbar('يرجى اختيار المدينة قبل المتابعة');
      return;
    }
    if (controller.currentStep.value == 4) {
      if (controller.selectedLatitude.value == 0.0 ||
          controller.selectedLongitude.value == 0.0) {
        Get.snackbar(
          'تنبيه',
          'يرجى تحديد الموقع من الخريطة قبل المتابعة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
    }
    if (controller.currentStep.value < 5) {
      controller.currentStep.value++;
    }
  }
}

class RestaurantTypeSelector extends StatelessWidget {
  final RestaurantController controller;

  const RestaurantTypeSelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.restaurantTypes.map((type) {
                final isSelected =
                    controller.selectedRestaurantTypes.contains(type);
                return FilterChip(
                  label: Text(type, style: GoogleFonts.cairo()),
                  selected: isSelected,
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  showCheckmark: false,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedRestaurantTypes.add(type);
                    } else {
                      controller.selectedRestaurantTypes.remove(type);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ));
  }
}

class CitySelectorField extends StatelessWidget {
  final RestaurantController controller;

  const CitySelectorField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            isDense: true,
            value: controller.selectedCity.value.isEmpty
                ? null
                : controller.selectedCity.value,
            hint: Text('اختر المدينة', style: GoogleFonts.cairo()),
            decoration: InputDecoration(
              labelText: 'المدينة',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: const TextStyle(fontSize: 16, height: 1.8),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: controller.palestinianCities.map((String city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.selectedCity.value = newValue;
                controller.cityController.text = newValue;
              }
            },
          ),
        ],
      );
    });
  }
}
