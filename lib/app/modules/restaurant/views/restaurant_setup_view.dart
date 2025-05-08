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
                          onPressed: () async {
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
                  content: RestaurantImagesSection(controller: controller),
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
                          RestaurantNameField(
                              controller: controller.nameController),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('نوع المطعم',
                                  style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              RestaurantTypeSelector(
                                selectedTypes:
                                    controller.selectedRestaurantTypes,
                                allTypes: controller.restaurantTypes,
                              ),
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
                        CitySelectorField(
                          controller: controller.cityController,
                          selectedCity: controller.selectedCity,
                          cityList: controller.palestinianCities,
                        ),
                        const SizedBox(height: 16),
                        AddressInputField(
                          controller: controller.addressController,
                          onRestore: () async {
                            if (controller.selectedLatitude.value != null &&
                                controller.selectedLongitude.value != null) {
                              final newAddress = await controller.getAddress(
                                controller.selectedLatitude.value!,
                                controller.selectedLongitude.value!,
                              );
                              controller.addressController.text = newAddress;
                              controller.isAddressManuallyEdited = false;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        MapLocationPicker(
                          markers: controller.markers,
                          onTap: controller.onMapTap,
                          onCameraMove: controller.onCameraMove,
                          onConfirm: () {
                            if (controller.selectedLatitude.value != null &&
                                controller.selectedLongitude.value != null) {
                              showSuccessSnackbar(
                                  'تم', 'تم تأكيد موقع المطعم بنجاح');
                            } else {
                              showErrorSnackbar(
                                  'الرجاء اختيار موقع على الخريطة أولاً');
                            }
                          },
                          onGetCurrentLocation:
                              controller.updateCurrentLocation,
                          isMapMoved: controller.isMapMoved,
                          lat: controller.selectedLatitude as RxDouble,
                          lon: controller.selectedLongitude as RxDouble,
                          onMapCreated: controller.onMapCreated,
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
                  content: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // البحث عن أول يوم مفتوح
                            final firstOpenDayIndex = controller.workingDays
                                .indexWhere((day) => day.isOpen);
                            if (firstOpenDayIndex == -1) {
                              showErrorSnackbar(
                                  'الرجاء تفعيل يوم واحد على الأقل');
                              return;
                            }

                            final firstOpenDay =
                                controller.workingDays[firstOpenDayIndex];
                            if (firstOpenDay.timeRanges.isEmpty) {
                              showErrorSnackbar(
                                  'الرجاء إضافة فترات عمل لليوم المفتوح');
                              return;
                            }

                            // نسخ الأوقات لجميع الأيام المفتوحة
                            for (var i = 0;
                                i < controller.workingDays.length;
                                i++) {
                              if (i != firstOpenDayIndex &&
                                  controller.workingDays[i].isOpen) {
                                controller.workingDays[i] =
                                    controller.workingDays[i].copyWith(
                                  timeRanges: List<TimeRange>.from(
                                      firstOpenDay.timeRanges),
                                );
                              }
                            }

                            Get.snackbar(
                              'تم النسخ',
                              'تم نسخ فترات العمل لجميع الأيام المفتوحة',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: Text(
                            'نسخ نفس الأوقات لجميع الأيام',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.workingDays.length,
                        itemBuilder: (context, index) {
                          final day = controller.workingDays[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      day.name,
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: day.isOpen,
                                    onChanged: (value) {
                                      final updatedDay =
                                          day.copyWith(isOpen: value);
                                      controller.workingDays[index] =
                                          updatedDay;
                                      controller.validateWorkingHours();
                                    },
                                  ),
                                ],
                              ),
                              children: [
                                if (day.isOpen) ...[
                                  Obx(() {
                                    final error = controller
                                        .getDayValidationError(day.name);
                                    if (error != null) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Text(
                                          error,
                                          style: GoogleFonts.cairo(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }),
                                  ...day.timeRanges
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final rangeIndex = entry.key;
                                    final range = entry.value;
                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        final isSmallScreen =
                                            constraints.maxWidth < 400;
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            alignment:
                                                WrapAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: isSmallScreen
                                                    ? constraints.maxWidth
                                                    : constraints.maxWidth *
                                                        0.4,
                                                child: TextButton.icon(
                                                  onPressed: () async {
                                                    final time =
                                                        await showTimePicker(
                                                      context: context,
                                                      initialTime: range.start,
                                                      builder:
                                                          (context, child) {
                                                        return Theme(
                                                          data:
                                                              Theme.of(context)
                                                                  .copyWith(
                                                            timePickerTheme:
                                                                TimePickerThemeData(
                                                              backgroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .cardColor,
                                                              hourMinuteShape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                side:
                                                                    BorderSide(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                              dayPeriodShape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                side:
                                                                    BorderSide(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                              dayPeriodColor:
                                                                  Colors
                                                                      .transparent,
                                                              dayPeriodTextColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                              dayPeriodBorderSide:
                                                                  BorderSide(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            textButtonTheme:
                                                                TextButtonThemeData(
                                                              style: TextButton
                                                                  .styleFrom(
                                                                foregroundColor:
                                                                    Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                              ),
                                                            ),
                                                          ),
                                                          child: child!,
                                                        );
                                                      },
                                                    );
                                                    if (time != null) {
                                                      final updatedRange =
                                                          TimeRange(
                                                        start: time,
                                                        end: range.end,
                                                      );
                                                      final updatedRanges =
                                                          List<TimeRange>.from(
                                                              day.timeRanges);
                                                      updatedRanges[
                                                              rangeIndex] =
                                                          updatedRange;
                                                      controller.workingDays[
                                                          index] = day.copyWith(
                                                        timeRanges:
                                                            updatedRanges,
                                                      );
                                                      controller
                                                          .validateWorkingHours();
                                                    }
                                                  },
                                                  icon: const Icon(
                                                      Icons.access_time),
                                                  label: Text(
                                                    'من: ${range.start.hour.toString().padLeft(2, '0')}:${range.start.minute.toString().padLeft(2, '0')}',
                                                    style: GoogleFonts.cairo(),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: isSmallScreen
                                                    ? constraints.maxWidth
                                                    : constraints.maxWidth *
                                                        0.4,
                                                child: TextButton.icon(
                                                  onPressed: () async {
                                                    final time =
                                                        await showTimePicker(
                                                      context: context,
                                                      initialTime: range.end,
                                                      builder:
                                                          (context, child) {
                                                        return Theme(
                                                          data:
                                                              Theme.of(context)
                                                                  .copyWith(
                                                            timePickerTheme:
                                                                TimePickerThemeData(
                                                              backgroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .cardColor,
                                                              hourMinuteShape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                side:
                                                                    BorderSide(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                              dayPeriodShape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                side:
                                                                    BorderSide(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                              dayPeriodColor:
                                                                  Colors
                                                                      .transparent,
                                                              dayPeriodTextColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                              dayPeriodBorderSide:
                                                                  BorderSide(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            textButtonTheme:
                                                                TextButtonThemeData(
                                                              style: TextButton
                                                                  .styleFrom(
                                                                foregroundColor:
                                                                    Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                              ),
                                                            ),
                                                          ),
                                                          child: child!,
                                                        );
                                                      },
                                                    );
                                                    if (time != null) {
                                                      if (time.hour <
                                                              range
                                                                  .start.hour ||
                                                          (time.hour ==
                                                                  range.start
                                                                      .hour &&
                                                              time.minute <=
                                                                  range.start
                                                                      .minute)) {
                                                        showErrorSnackbar(
                                                            'وقت النهاية يجب أن يكون بعد وقت البداية');
                                                        return;
                                                      }
                                                      final updatedRange =
                                                          TimeRange(
                                                        start: range.start,
                                                        end: time,
                                                      );
                                                      final updatedRanges =
                                                          List<TimeRange>.from(
                                                              day.timeRanges);
                                                      updatedRanges[
                                                              rangeIndex] =
                                                          updatedRange;
                                                      controller.workingDays[
                                                          index] = day.copyWith(
                                                        timeRanges:
                                                            updatedRanges,
                                                      );
                                                      controller
                                                          .validateWorkingHours();
                                                    }
                                                  },
                                                  icon: const Icon(
                                                      Icons.access_time),
                                                  label: Text(
                                                    'إلى: ${range.end.hour.toString().padLeft(2, '0')}:${range.end.minute.toString().padLeft(2, '0')}',
                                                    style: GoogleFonts.cairo(),
                                                  ),
                                                ),
                                              ),
                                              if (!isSmallScreen)
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red),
                                                  onPressed: () {
                                                    final updatedRanges =
                                                        List<TimeRange>.from(
                                                            day.timeRanges);
                                                    updatedRanges
                                                        .removeAt(rangeIndex);
                                                    controller.workingDays[
                                                        index] = day.copyWith(
                                                      timeRanges: updatedRanges,
                                                    );
                                                    controller
                                                        .validateWorkingHours();
                                                  },
                                                ),
                                              if (isSmallScreen)
                                                SizedBox(
                                                  width: constraints.maxWidth,
                                                  child: TextButton.icon(
                                                    onPressed: () {
                                                      final updatedRanges =
                                                          List<TimeRange>.from(
                                                              day.timeRanges);
                                                      updatedRanges
                                                          .removeAt(rangeIndex);
                                                      controller.workingDays[
                                                          index] = day.copyWith(
                                                        timeRanges:
                                                            updatedRanges,
                                                      );
                                                      controller
                                                          .validateWorkingHours();
                                                    },
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red),
                                                    label: Text(
                                                      'حذف الفترة',
                                                      style: GoogleFonts.cairo(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          final now = TimeOfDay.now();
                                          final updatedRanges =
                                              List<TimeRange>.from(
                                                  day.timeRanges);
                                          updatedRanges.add(TimeRange(
                                            start: now,
                                            end: TimeOfDay(
                                                hour: now.hour + 1,
                                                minute: now.minute),
                                          ));
                                          controller.workingDays[index] =
                                              day.copyWith(
                                            timeRanges: updatedRanges,
                                          );
                                          controller.validateWorkingHours();
                                        },
                                        icon: const Icon(Icons.add),
                                        label: Text(
                                          'إضافة فترة عمل',
                                          style: GoogleFonts.cairo(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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
