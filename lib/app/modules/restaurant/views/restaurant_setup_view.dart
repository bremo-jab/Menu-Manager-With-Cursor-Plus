import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';
import 'package:menu_manager/app/widgets/custom_button.dart';
import 'package:menu_manager/app/widgets/custom_text_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:menu_manager/app/controllers/auth_controller.dart';

class RestaurantSetupView extends GetView<RestaurantController> {
  const RestaurantSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعداد المطعم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => Get.find<AuthController>().signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'معلومات المطعم',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.typeController,
                  label: 'نوع المطعم',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال نوع المطعم';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.cityController,
                  label: 'المدينة',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال المدينة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.addressController,
                  label: 'العنوان',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال العنوان';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'الموقع الجغرافي',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
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
                const SizedBox(height: 16),
                const Text(
                  'أيام وساعات العمل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(7, (index) {
                  final day = controller.weekDays[index];
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(day),
                          ),
                          Expanded(
                            child: CustomTextField(
                              controller:
                                  controller.workingHoursControllers[index][0],
                              label: 'من',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              controller:
                                  controller.workingHoursControllers[index][1],
                              label: 'إلى',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                const Text(
                  'الشعار والصور',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: controller.pickLogo,
                        text: 'اختيار الشعار',
                        icon: Icons.image,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        onPressed: controller.pickImages,
                        text: 'اختيار الصور',
                        icon: Icons.photo_library,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'طرق الدفع',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...controller.paymentMethods.map((method) {
                  return CheckboxListTile(
                    title: Text(method),
                    value: controller.selectedPaymentMethods.contains(method),
                    onChanged: (value) {
                      if (value == true) {
                        controller.selectedPaymentMethods.add(method);
                      } else {
                        controller.selectedPaymentMethods.remove(method);
                      }
                    },
                  );
                }),
                const SizedBox(height: 16),
                const Text(
                  'خيارات الخدمة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...controller.serviceOptions.map((option) {
                  return CheckboxListTile(
                    title: Text(option),
                    value: controller.selectedServiceOptions.contains(option),
                    onChanged: (value) {
                      if (value == true) {
                        controller.selectedServiceOptions.add(option);
                      } else {
                        controller.selectedServiceOptions.remove(option);
                      }
                    },
                  );
                }),
                const SizedBox(height: 32),
                CustomButton(
                  onPressed: controller.saveRestaurant,
                  text: 'حفظ',
                  isLoading: controller.isLoading.value,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
