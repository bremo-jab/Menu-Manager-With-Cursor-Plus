import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_manager/app/data/models/restaurant_model.dart';
import 'package:menu_manager/app/services/restaurant_service.dart';
import 'package:menu_manager/app/routes/app_pages.dart';
import 'package:uuid/uuid.dart';

class RestaurantController extends GetxController {
  final RestaurantService _restaurantService = Get.find<RestaurantService>();
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final typeController = TextEditingController();
  final descriptionController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final workingHoursControllers = List.generate(
    7,
    (_) => [TextEditingController(), TextEditingController()],
  );

  final weekDays = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  final paymentMethods = [
    'نقداً',
    'بطاقة',
    'إلكتروني',
  ];

  final serviceOptions = [
    'داخل المطعم',
    'توصيل',
    'طلب مسبق',
    'حجز',
  ];

  final selectedPaymentMethods = <String>[].obs;
  final selectedServiceOptions = <String>[].obs;
  final markers = <Marker>{}.obs;
  final logoFile = Rxn<XFile>();
  final imagesFiles = <XFile>[].obs;
  final isLoading = false.obs;

  late GoogleMapController mapController;
  final initialPosition = const LatLng(24.7136, 46.6753); // Riyadh coordinates
  final selectedPosition = Rxn<LatLng>();

  @override
  void onInit() {
    super.onInit();
    selectedPosition.value = initialPosition;
    updateMarker();
  }

  @override
  void onClose() {
    nameController.dispose();
    typeController.dispose();
    descriptionController.dispose();
    cityController.dispose();
    addressController.dispose();
    for (var controllers in workingHoursControllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void onMapTap(LatLng position) {
    selectedPosition.value = position;
    updateMarker();
  }

  void updateMarker() {
    if (selectedPosition.value != null) {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('restaurant'),
          position: selectedPosition.value!,
          infoWindow: const InfoWindow(title: 'موقع المطعم'),
        ),
      );
    }
  }

  Future<void> pickLogo() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        logoFile.value = image;
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء اختيار الشعار',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pickImages() async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        imagesFiles.addAll(images);
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء اختيار الصور',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> saveRestaurant() async {
    if (!formKey.currentState!.validate()) return;
    if (logoFile.value == null) {
      Get.snackbar(
        'خطأ',
        'الرجاء اختيار شعار للمطعم',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (imagesFiles.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء اختيار صور للمطعم',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedPaymentMethods.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء اختيار طريقة دفع واحدة على الأقل',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedServiceOptions.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء اختيار خيار خدمة واحد على الأقل',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final restaurant = RestaurantModel(
        id: const Uuid().v4(),
        name: nameController.text,
        type: typeController.text,
        description: descriptionController.text,
        city: cityController.text,
        address: addressController.text,
        latitude: selectedPosition.value!.latitude,
        longitude: selectedPosition.value!.longitude,
        workingDays: weekDays,
        workingHours: Map.fromIterables(
          weekDays,
          workingHoursControllers.map((controllers) =>
              '${controllers[0].text} - ${controllers[1].text}'),
        ),
        logoUrl: '', // Will be updated after upload
        imagesUrls: [], // Will be updated after upload
        paymentMethods: selectedPaymentMethods,
        serviceOptions: selectedServiceOptions,
      );

      await _restaurantService.createRestaurant(restaurant);
      Get.offAllNamed(Routes.MENU);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حفظ بيانات المطعم',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
