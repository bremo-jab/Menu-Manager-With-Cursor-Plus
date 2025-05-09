import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_manager/app/data/models/restaurant_model.dart';
import 'package:menu_manager/app/models/restaurant.dart';
import 'package:menu_manager/app/models/working_day_model.dart';
import 'package:menu_manager/app/services/restaurant_service.dart';
import 'package:menu_manager/app/routes/app_pages.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:menu_manager/app/services/cloudinary_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:menu_manager/utils/snackbar_helper.dart';
import 'package:http/http.dart' as http;
import 'package:menu_manager/app/models/cloudinary_image.dart';
import 'dart:async';
import 'package:menu_manager/app/services/opencage_service.dart';
import 'package:menu_manager/app/services/google_maps_service.dart';
import 'package:menu_manager/app/utils/snackbar_helper.dart';

class RestaurantController extends GetxController {
  final RestaurantService _restaurantService = Get.find<RestaurantService>();
  final formKey = GlobalKey<FormState>();
  final socialLinksFormKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController cityController;
  late final TextEditingController addressController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController websiteController;
  late final TextEditingController facebookController;
  late final TextEditingController instagramController;
  late final TextEditingController twitterController;
  late final TextEditingController whatsappController;
  late final List<List<TextEditingController>> workingHoursControllers;

  final weekDays = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  final workingDays = <WorkingDayModel>[].obs;
  final dayValidationErrors = <String, String>{}.obs;

  final paymentMethods = [
    'نقداً',
    'بطاقة ائتمان',
    'محفظة إلكترونية',
  ];

  final serviceOptions = [
    'توصيل',
    'داخل المطعم',
    'طلب مسبق',
    'حجز',
  ];

  final isLoading = false.obs;
  final currentStep = 0.obs;
  final logoImage = Rx<File?>(null);
  final galleryImages = <File>[].obs;
  final images = <File>[].obs;
  final cloudinaryImages = <CloudinaryImage>[].obs;
  final imageUrls = <String>[].obs;
  final isUploadingImages = false.obs;
  final uploadProgress = 0.0.obs;
  final markers = <Marker>{}.obs;
  final selectedPaymentMethods = <String>[].obs;
  final selectedServiceOptions = <String>[].obs;
  final wantsEmailUpdates = false.obs;
  final isMapReady = false.obs;
  var isPhoneVerified = false.obs;

  GoogleMapController? mapController;
  final initialPosition = const LatLng(24.7136, 46.6753); // الرياض
  LatLng currentLocation = const LatLng(0, 0); // موقع افتراضي
  final isMapMoved = false.obs;

  final restaurantTypes = [
    'مشاوي',
    'مأكولات بحرية',
    'وجبات سريعة',
    'مأكولات شرقية',
    'مأكولات غربية',
    'نباتي',
    'وجبات صحية',
    'حلويات',
    'شعبي',
    'بيتزا وباستا',
    'ساندويشات',
    'مقهى / كافيه',
  ];

  final selectedRestaurantTypes = <String>[].obs;

  // New variables for location
  final selectedCity = ''.obs;
  final selectedLatitude = 0.0.obs;
  final selectedLongitude = 0.0.obs;
  final address = ''.obs;

  // Palestinian cities list
  final palestinianCities = [
    'القدس',
    'رام الله',
    'نابلس',
    'الخليل',
    'بيت لحم',
    'غزة',
    'جنين',
    'طولكرم',
    'قلقيلية',
    'أريحا',
    'رفح',
    'خان يونس',
    'البيرة',
    'طوباس',
    'سلفيت',
  ];

  bool isAddressManuallyEdited = false;

  // Working Hours
  final workingHours = <TimeOfDay?>[].obs;
  final closingHours = <TimeOfDay?>[].obs;

  // إضافة قائمة جديدة لتخزين الصور المطلوب حذفها
  final imagesToDelete = <String>[].obs;

  // Page Controller
  final pageController = PageController();
  final currentPage = 0.obs;
  final totalSteps = 6.obs; // عدد البطاقات الكاملة

  // Phone verification
  final TextEditingController otpController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _requestLocationPermission();
    _initializeWorkingDays();
    markers.add(
      Marker(
        markerId: const MarkerId('restaurant'),
        position: initialPosition,
      ),
    );
    ever(currentStep, (_) {
      if (Get.isRegistered<GoogleMapController>()) {
        Get.delete<GoogleMapController>();
      }
    });
    // Initialize working hours arrays with null values for each day
    workingHours.value = List.generate(7, (_) => null);
    closingHours.value = List.generate(7, (_) => null);
    loadTempData();
    nameController.addListener(saveTempData);
    phoneController.addListener(saveTempData);
    descriptionController.addListener(saveTempData);

    // Check phone verification status
    FirebaseAuth.instance.currentUser?.reload().then((_) {
      isPhoneVerified.value =
          FirebaseAuth.instance.currentUser?.phoneNumber != null;
    });

    // تحميل بيانات المطعم إذا كان المستخدم يملك مطعماً
    loadRestaurantData();
  }

  Future<void> loadRestaurantData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final restaurant = await _restaurantService.getRestaurant(user.uid);
      if (restaurant != null) {
        // تعيين قيم المدينة
        selectedCity.value = restaurant.city;
        cityController.text = restaurant.city;

        // تعيين باقي القيم
        nameController.text = restaurant.name;
        descriptionController.text = restaurant.description;
        addressController.text = restaurant.address;

        // تعيين ساعات العمل
        if (restaurant.workingHours.isNotEmpty) {
          for (var entry in restaurant.workingHours.entries) {
            final dayIndex = restaurant.workingDays.indexOf(entry.key);
            if (dayIndex != -1) {
              final timeParts = entry.value.split(':');
              if (timeParts.length == 2) {
                final hour = int.parse(timeParts[0]);
                final minute = int.parse(timeParts[1]);
                workingHours[dayIndex] = TimeOfDay(hour: hour, minute: minute);
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error loading restaurant data: $e');
    }
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    cityController = TextEditingController();
    addressController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    websiteController = TextEditingController();
    facebookController = TextEditingController();
    instagramController = TextEditingController();
    twitterController = TextEditingController();
    whatsappController = TextEditingController();
    workingHoursControllers = List.generate(
      7,
      (index) => [
        TextEditingController(),
        TextEditingController(),
      ],
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      emailController.text = user.email!;
    }
  }

  void _initializeWorkingDays() {
    workingDays.value = weekDays
        .map((day) => WorkingDayModel(
              name: day,
              isOpen: false,
              timeRanges: [],
            ))
        .toList();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      // تم منح الإذن
      print('Location permission granted');
    } else {
      // تم رفض الإذن
      print('Location permission denied');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    cityController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    websiteController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    twitterController.dispose();
    whatsappController.dispose();
    for (var controllers in workingHoursControllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    if (Get.isRegistered<GoogleMapController>()) {
      mapController!.dispose();
    }
    pageController.dispose();
    otpController.dispose();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    isMapReady.value = true;

    if (!Get.isRegistered<GoogleMapController>()) {
      Get.put(controller, permanent: true);
    }
  }

  Future<String?> getBestAddressFromCoordinates(double lat, double lng) async {
    try {
      final openCageService = Get.find<OpenCageService>();
      final googleMapsService = Get.find<GoogleMapsService>();

      final openCageResult = await openCageService.getAddress(lat, lng);
      final googleMapsResult = await googleMapsService.getAddress(lat, lng);

      String? address;
      if (openCageResult != null) {
        address = openCageResult['formatted'] as String?;
      }
      if (!_isValidArabicAddress(address) && googleMapsResult != null) {
        address = googleMapsResult['formatted'] as String?;
      }
      if (!_isValidArabicAddress(address)) {
        return null;
      }
      return _cleanArabicAddress(address!);
    } catch (e) {
      print('Error getting address from services: $e');
      return null;
    }
  }

  bool _isValidArabicAddress(String? address) {
    if (address == null) return false;
    if (address.toLowerCase().contains('unnamed') ||
        address.toLowerCase().contains('unknown') ||
        address.toLowerCase().contains('null')) {
      return false;
    }
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(address);
  }

  String _cleanArabicAddress(String address) {
    List<String> parts = address.split(',').map((e) => e.trim()).toList();
    final arabicRegex = RegExp(r'^[\u0600-\u06FF\s0-9]+$');
    List<String> cleaned = parts.where((part) {
      return arabicRegex.hasMatch(part) &&
          !part.toLowerCase().contains('unnamed') &&
          !part.toLowerCase().contains('unknown') &&
          !part.toLowerCase().contains('null');
    }).toList();
    return cleaned.join('، ');
  }

  Future<String> getAddress(double lat, double lon) async {
    return await getBestAddressFromCoordinates(lat, lon) ??
        'لم يتم العثور على عنوان';
  }

  Future<void> onMapTap(LatLng position) async {
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('restaurant'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    if (!isAddressManuallyEdited) {
      final address = await getAddress(position.latitude, position.longitude);
      addressController.text = address;
    }

    selectedLatitude.value = position.latitude;
    selectedLongitude.value = position.longitude;

    showCustomSnackbar(
      'الموقع',
      'تم تحديد موقع المطعم بنجاح',
    );
  }

  Future<ImageSource?> _chooseImageSource() async {
    return await showMaterialModalBottomSheet<ImageSource>(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.blue),
              ),
              title: Text(
                'التقاط من الكاميرا',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library, color: Colors.green),
              ),
              title: Text(
                'اختيار من المعرض',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cancel, color: Colors.red),
              ),
              title: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => Get.back(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      enableDrag: true,
      isDismissible: true,
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<bool> _showPermissionInfoIfNeeded(String contextType) async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('hasShownPermissionInfo') ?? false;

    if (hasShown) return true;

    await Get.dialog(
      AlertDialog(
        title: const Text('تنبيه الخصوصية'),
        content: Text(
          'يحتاج التطبيق للوصول إلى $contextType لتتمكن من اختيار صور المطعم أو التقاط صورة الشعار. نحن نحترم خصوصيتك، ولا يتم استخدام الصور لأي غرض آخر.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('متابعة'),
          ),
        ],
      ),
    );

    await prefs.setBool('hasShownPermissionInfo', true);
    return true;
  }

  Future<void> _showPermissionDialog({
    required String title,
    required String message,
  }) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  void pickLogo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        logoImage.value = File(image.path);
      }
    } catch (e) {
      showCustomSnackbar('خطأ', 'حدث خطأ أثناء اختيار الشعار');
    }
  }

  void deleteLogo() {
    logoImage.value = null;
    showCustomSnackbar('نجاح', 'تم حذف الشعار بنجاح');
  }

  void pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> selectedImages = await picker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        images.addAll(selectedImages.map((image) => File(image.path)));
      }
    } catch (e) {
      showCustomSnackbar('خطأ', 'حدث خطأ أثناء اختيار الصور');
    }
  }

  void removeImage(int index) {
    if (index < images.length) {
      images.removeAt(index);
    } else {
      final cloudIndex = index - images.length;
      if (cloudIndex < cloudinaryImages.length) {
        cloudinaryImages.removeAt(cloudIndex);
      }
    }
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = images.removeAt(oldIndex);
    images.insert(newIndex, item);
    showCustomSnackbar('نجاح', 'تم إعادة ترتيب الصور بنجاح');
  }

  Future<void> saveRestaurant() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showCustomSnackbar('خطأ', 'يجب تسجيل الدخول أولاً');
        return;
      }

      // رفع الصور الجديدة إلى Cloudinary داخل مجلد المستخدم
      isUploadingImages.value = true;
      uploadProgress.value = 0.0;

      try {
        // رفع صورة الشعار
        if (logoImage.value != null) {
          final logoUrl =
              await _uploadImageToCloudinary(logoImage.value!, 'logo');
          if (logoUrl.isNotEmpty) {
            imageUrls.add(logoUrl);
          }
        }

        // رفع صور المطعم
        for (var i = 0; i < images.length; i++) {
          final file = images[i];
          final url = await _uploadImageToCloudinary(file, 'gallery');
          if (url.isNotEmpty) {
            imageUrls.add(url);
          }
          uploadProgress.value = (i + 1) / images.length;
        }
      } catch (e) {
        showCustomSnackbar('فشل', 'في رفع بعض الصور');
        return;
      } finally {
        isUploadingImages.value = false;
        uploadProgress.value = 0.0;
      }

      // حذف الصور المطلوب حذفها من Cloudinary
      for (var publicId in imagesToDelete) {
        try {
          await CloudinaryService.deleteImage(publicId);
        } catch (e) {
          print('Error deleting image from Cloudinary: $e');
        }
      }

      // تحويل قائمة cloudinaryImages إلى التنسيق المطلوب
      final imageData = cloudinaryImages
          .map((img) => {
                'url': img.url,
                'public_id': img.publicId,
              })
          .toList();

      final restaurant = Restaurant(
        id: '',
        name: nameController.text,
        description: descriptionController.text,
        address: addressController.text,
        phone: phoneController.text,
        email: emailController.text,
        website: websiteController.text,
        instagram: instagramController.text,
        facebook: facebookController.text,
        twitter: twitterController.text,
        city: selectedCity.value,
        workingHours: workingHours
            .map((time) => time?.format(Get.context!) ?? '')
            .toList(),
        closingHours: closingHours
            .map((time) => time?.format(Get.context!) ?? '')
            .toList(),
        ownerId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docId = const Uuid().v4();
      await _restaurantService.createRestaurant(
        {
          ...restaurant.toMap(),
          'imageData': imageData,
        },
        logoImage.value,
        images,
      );

      await _restaurantService.updateRestaurant(
        docId,
        {
          'name': nameController.text,
          'description': descriptionController.text,
          'address': addressController.text,
          'phone': phoneController.text,
          'email': emailController.text,
          'website': websiteController.text,
          'instagram': instagramController.text,
          'facebook': facebookController.text,
          'twitter': twitterController.text,
          'city': selectedCity.value,
          'workingHours': workingHours
              .map((time) => time?.format(Get.context!) ?? '')
              .toList(),
          'closingHours': closingHours
              .map((time) => time?.format(Get.context!) ?? '')
              .toList(),
          'imageData': imageData,
        },
      );

      showCustomSnackbar('نجاح', 'تم حفظ معلومات المطعم بنجاح');
      Get.offAllNamed('/home');
    } catch (e) {
      showCustomSnackbar('خطأ', 'حدث خطأ أثناء حفظ معلومات المطعم');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      // التحقق من تفعيل خدمة الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showCustomSnackbar('خدمة الموقع غير مفعّلة', 'يرجى تفعيل GPS');
        return null;
      }

      // التحقق من الأذونات
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showCustomSnackbar(
              'تم رفض صلاحية الوصول للموقع', 'فعّل GPS وحاول مرة أخرى');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showCustomSnackbar(
            'صلاحية الوصول مرفوضة نهائيًا', 'يرجى تفعيلها من إعدادات الجهاز');
        return null;
      }

      // الحصول على الموقع الحالي
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } on TimeoutException {
      showCustomSnackbar('انتهت مهلة تحديد الموقع', 'يرجى المحاولة مرة أخرى');
      return null;
    } catch (e) {
      print('Error getting location: $e');
      if (e is LocationServiceDisabledException) {
        showCustomSnackbar('خدمة الموقع غير مفعّلة', 'فعّل GPS وحاول مرة أخرى');
      } else if (e is PermissionDeniedException) {
        showCustomSnackbar(
            'تم رفض صلاحية الموقع', 'فعّل الصلاحية من الإعدادات');
      } else {
        showCustomSnackbar('حدث خطأ أثناء تحديد الموقع', '${e.toString()}');
      }
      return null;
    }
  }

  Future<void> updateCurrentLocation() async {
    try {
      if (!isMapReady.value || mapController == null) {
        showCustomSnackbar('الخريطة لم تُحمّل بعد', 'الرجاء الانتظار...');
        return;
      }

      final position = await getCurrentLocation();
      if (position == null) return;

      final latLng = LatLng(position.latitude, position.longitude);

      // تحديث موقع الكاميرا
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
            zoom: 15,
          ),
        ),
      );

      // تحديث العلامة على الخريطة
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('restaurant'),
          position: latLng,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'موقع المطعم'),
        ),
      );

      // تحديث العنوان إذا لم يتم تعديله يدوياً
      if (!isAddressManuallyEdited) {
        final address = await getAddress(position.latitude, position.longitude);
        if (address.isNotEmpty) {
          addressController.text = address;
        }
      }

      // تحديث إحداثيات الموقع
      selectedLatitude.value = position.latitude;
      selectedLongitude.value = position.longitude;

      // إظهار رسالة نجاح
      showCustomSnackbar(
        'الموقع',
        'تم تحديد موقعك الحالي',
      );
    } catch (e) {
      print('Error updating location: $e');
      if (e is LocationServiceDisabledException) {
        showCustomSnackbar('خدمة الموقع غير مفعّلة', 'فعّل GPS وحاول مرة أخرى');
      } else if (e is PermissionDeniedException) {
        showCustomSnackbar(
            'تم رفض صلاحية الموقع', 'فعّل الصلاحية من الإعدادات');
      } else {
        showCustomSnackbar('حدث خطأ أثناء تحديث الموقع', '${e.toString()}');
      }
    }
  }

  void onCameraMove(CameraPosition position) {
    isMapMoved.value = true;
  }

  bool validateWorkingHours() {
    dayValidationErrors.clear();
    bool isValid = true;

    for (var i = 0; i < workingDays.length; i++) {
      final day = workingDays[i];
      String? error;

      if (day.isOpen) {
        if (day.timeRanges.isEmpty) {
          error = 'يجب إضافة فترة عمل واحدة على الأقل';
          isValid = false;
        } else {
          // التحقق من صحة كل فترة عمل
          for (var j = 0; j < day.timeRanges.length; j++) {
            final range = day.timeRanges[j];
            if (range.end.hour < range.start.hour ||
                (range.end.hour == range.start.hour &&
                    range.end.minute <= range.start.minute)) {
              error =
                  'وقت النهاية يجب أن يكون بعد وقت البداية في الفترة ${j + 1}';
              isValid = false;
              break;
            }
          }
        }
      }

      if (error != null) {
        dayValidationErrors[day.name] = error;
      }
    }

    return isValid;
  }

  String? getDayValidationError(String dayName) {
    return dayValidationErrors[dayName];
  }

  void onPhoneVerifiedSuccessfully() {
    isPhoneVerified.value = true;
  }

  void goToNextStep() {
    if (currentStep.value == 1 && !isPhoneVerified.value) {
      showCustomSnackbar('تحذير', 'يرجى التحقق من رقم الهاتف أولاً');
      return;
    }
    currentStep.value++;
  }

  Future<void> saveTempData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('temp_name', nameController.text);
    prefs.setString('temp_phone', phoneController.text);
    prefs.setString('temp_description', descriptionController.text);
  }

  Future<void> loadTempData() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('temp_name') ?? '';
    phoneController.text = prefs.getString('temp_phone') ?? '';
    descriptionController.text = prefs.getString('temp_description') ?? '';
  }

  Future<void> uploadImages() async {
    try {
      isUploadingImages.value = true;
      uploadProgress.value = 0.0;

      final totalImages = images.length;
      var uploadedCount = 0;

      for (var image in images) {
        try {
          final result =
              await CloudinaryService.uploadImage(image, 'restaurants');
          if (result != null) {
            cloudinaryImages.add(result);
            imageUrls.add(result.url);
          }
          uploadedCount++;
          uploadProgress.value = uploadedCount / totalImages;
        } catch (e) {
          print('Error uploading image: $e');
          // Continue with next image even if one fails
        }
      }

      if (cloudinaryImages.isEmpty) {
        throw Exception('فشل رفع جميع الصور');
      }

      showCustomSnackbar(
        'نجاح',
        'تم رفع الصور بنجاح',
      );
    } catch (e) {
      print('Error in uploadImages: $e');
      showCustomSnackbar(
        'خطأ',
        'فشل رفع الصور، يرجى المحاولة مجدداً',
      );
    } finally {
      isUploadingImages.value = false;
      uploadProgress.value = 0.0;
    }
  }

  void goToNextPage() {
    if (currentPage.value < totalSteps.value - 1) {
      currentPage.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToPreviousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> sendOTP() async {
    if (phoneController.text.isEmpty) {
      showCustomSnackbar('خطأ', 'يرجى إدخال رقم الهاتف');
      return;
    }

    isLoading.value = true;
    try {
      // TODO: Implement OTP sending logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      isPhoneVerified.value = true;
      showCustomSnackbar(
        'تم',
        'تم إرسال رمز التحقق',
      );
    } catch (e) {
      showCustomSnackbar(
        'خطأ',
        'حدث خطأ أثناء إرسال رمز التحقق',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP() async {
    if (otpController.text.isEmpty) {
      showCustomSnackbar('خطأ', 'يرجى إدخال رمز التحقق');
      return;
    }

    isLoading.value = true;
    try {
      // TODO: Implement OTP verification logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      isPhoneVerified.value = true;
      showCustomSnackbar(
        'تم',
        'تم التحقق من رقم الهاتف بنجاح',
      );
    } catch (e) {
      showCustomSnackbar(
        'خطأ',
        'رمز التحقق غير صحيح',
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool validateCurrentPage() {
    switch (currentPage.value) {
      case 0: // صور المطعم
        if (logoImage.value == null || images.isEmpty) {
          showCustomSnackbar(
            'خطأ',
            'يرجى اختيار صورة الشعار وصورة واحدة على الأقل من صور المطعم قبل المتابعة',
          );
          return false;
        }
        break;
      case 1: // المعلومات الأساسية
        if (nameController.text.trim().isEmpty) {
          showCustomSnackbar(
            'خطأ',
            'يرجى إدخال اسم المطعم قبل المتابعة',
          );
          return false;
        }
        break;
      case 2: // نوع المطعم
        if (selectedRestaurantTypes.isEmpty) {
          showCustomSnackbar(
            'خطأ',
            'يرجى اختيار نوع واحد من أنواع المطاعم على الأقل',
          );
          return false;
        }
        break;
      case 3: // المدينة
        if (selectedCity.value.isEmpty) {
          showCustomSnackbar(
            'خطأ',
            'يرجى اختيار المدينة قبل المتابعة',
          );
          return false;
        }
        break;
      case 4: // الموقع
        if (selectedLatitude.value == 0.0 || selectedLongitude.value == 0.0) {
          showCustomSnackbar(
            'خطأ',
            'يرجى تحديد الموقع من الخريطة قبل المتابعة',
          );
          return false;
        }
        break;
      case 5: // رقم الهاتف
        if (!isPhoneVerified.value) {
          showCustomSnackbar(
            'خطأ',
            'يرجى توثيق رقم الهاتف قبل المتابعة',
          );
          return false;
        }
        break;
    }
    return true;
  }

  Future<String> _uploadImageToCloudinary(File image, String subfolder) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final folderName = 'restaurants/${user?.uid}/$subfolder';
      final response = await CloudinaryService.uploadImage(image, folderName);
      return response?.url ?? '';
    } catch (e) {
      print('فشل رفع الصورة: $e');
      return '';
    }
  }
}
