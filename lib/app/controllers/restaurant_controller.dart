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

    Get.snackbar(
      'الموقع',
      'تم تحديد موقع المطعم بنجاح',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
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

  Future<void> pickLogo() async {
    if (logoImage.value != null) {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('تأكيد تغيير الشعار'),
          content:
              const Text('هل أنت متأكد أنك تريد تغيير صورة الشعار الحالية؟'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('نعم'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    final source = await _chooseImageSource();
    if (source == null) return;

    await _showPermissionInfoIfNeeded(
        source == ImageSource.camera ? 'الكاميرا' : 'المعرض');

    final permission = source == ImageSource.camera
        ? Permission.camera
        : (Platform.isAndroid ? Permission.storage : Permission.photos);

    final status = await permission.request();

    if (status.isGranted) {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        logoImage.value = File(image.path);
      }
    } else if (status.isPermanentlyDenied) {
      await _showPermissionDialog(
        title: 'إذن مرفوض نهائيًا',
        message:
            'يرجى فتح إعدادات التطبيق للسماح بالوصول إلى الكاميرا أو المعرض.',
      );
    } else {
      Get.snackbar(
        'إذن مرفوض',
        'لا يمكن تحميل صورة الشعار بدون إذن.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteLogo() async {
    if (logoImage.value == null) return;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد حذف الشعار'),
        content: const Text('هل أنت متأكد أنك تريد حذف الشعار الحالي؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      logoImage.value = null;
      Get.snackbar(
        'تم الحذف',
        'تم حذف الشعار بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
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

  Future<void> pickImages() async {
    final source = await _chooseImageSource();
    if (source == null) return;

    await _showPermissionInfoIfNeeded(
        source == ImageSource.camera ? 'الكاميرا' : 'المعرض');

    final permission = source == ImageSource.camera
        ? Permission.camera
        : (Platform.isAndroid ? Permission.storage : Permission.photos);

    final status = await permission.request();

    if (status.isGranted) {
      final picker = ImagePicker();
      if (source == ImageSource.camera) {
        final XFile? image = await picker.pickImage(source: source);
        if (image != null) {
          if (images.length >= 10) {
            Get.snackbar(
              'تنبيه',
              'يمكنك إضافة 10 صور كحد أقصى',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return;
          }
          final file = File(image.path);
          images.add(file);
        }
      } else {
        final List<XFile> selectedImages = await picker.pickMultiImage();
        if (selectedImages.isNotEmpty) {
          final remainingSlots = 10 - images.length;
          if (remainingSlots <= 0) {
            Get.snackbar(
              'تنبيه',
              'يمكنك إضافة 10 صور كحد أقصى',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return;
          }

          final imagesToAdd = selectedImages.take(remainingSlots).toList();
          for (var image in imagesToAdd) {
            images.add(File(image.path));
          }
        }
      }
    } else if (status.isPermanentlyDenied) {
      await _showPermissionDialog(
        title: 'إذن مرفوض نهائيًا',
        message:
            'يرجى فتح إعدادات التطبيق للسماح بالوصول إلى الكاميرا أو المعرض.',
      );
    } else {
      Get.snackbar(
        'إذن مرفوض',
        'لا يمكن تحميل الصور بدون إذن.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String? _extractPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2) {
        // تنسيق رابط Cloudinary: https://res.cloudinary.com/cloud_name/image/upload/v1234567890/folder/image.jpg
        final uploadIndex = pathSegments.indexOf('upload');
        if (uploadIndex != -1 && uploadIndex + 1 < pathSegments.length) {
          // نأخذ كل الأجزاء بعد 'upload' ونحذف الامتداد
          final publicId = pathSegments.sublist(uploadIndex + 1).join('/');
          return publicId.replaceAll(RegExp(r'\.[^/.]+$'), '');
        }
      }
      return null;
    } catch (e) {
      print('Error extracting public_id: $e');
      return null;
    }
  }

  Future<void> _deleteImageFromCloudinary(String url) async {
    try {
      final publicId = _extractPublicIdFromUrl(url);
      if (publicId != null) {
        await CloudinaryService.deleteImage(publicId);
      }
    } catch (e) {
      print('Error deleting image from Cloudinary: $e');
      rethrow;
    }
  }

  Future<void> removeImage(int index) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذه الصورة؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // نحذف من القائمتين معًا
      if (index < cloudinaryImages.length) {
        imagesToDelete.add(cloudinaryImages[index].publicId);
        cloudinaryImages.removeAt(index);
      }
      if (index < images.length) {
        images.removeAt(index);
      }

      images.refresh();
      cloudinaryImages.refresh();
    }
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final image = images.removeAt(oldIndex);
    images.insert(newIndex, image);

    if (oldIndex < cloudinaryImages.length &&
        newIndex < cloudinaryImages.length) {
      final cloudinaryImage = cloudinaryImages.removeAt(oldIndex);
      cloudinaryImages.insert(newIndex, cloudinaryImage);
    }
  }

  Future<void> saveRestaurant() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('خطأ', 'يجب تسجيل الدخول أولاً');
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
        showErrorSnackbar('فشل في رفع بعض الصور');
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

      Get.snackbar('نجاح', 'تم حفظ معلومات المطعم بنجاح');
      Get.offAllNamed('/home');
    } catch (e) {
      showErrorSnackbar('حدث خطأ أثناء حفظ معلومات المطعم');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      // التحقق من تفعيل خدمة الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showErrorSnackbar('خدمة الموقع غير مفعّلة. يرجى تفعيل GPS');
        return null;
      }

      // التحقق من الأذونات
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showErrorSnackbar('تم رفض صلاحية الوصول للموقع');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showErrorSnackbar(
            'صلاحية الوصول مرفوضة نهائيًا. يرجى تفعيلها من إعدادات الجهاز');
        return null;
      }

      // الحصول على الموقع الحالي
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } on TimeoutException {
      showErrorSnackbar('انتهت مهلة تحديد الموقع. يرجى المحاولة مرة أخرى');
      return null;
    } catch (e) {
      print('Error getting location: $e');
      if (e is LocationServiceDisabledException) {
        showErrorSnackbar('خدمة الموقع غير مفعّلة. فعّل GPS وحاول مرة أخرى.');
      } else if (e is PermissionDeniedException) {
        showErrorSnackbar('تم رفض صلاحية الموقع. فعّل الصلاحية من الإعدادات.');
      } else {
        showErrorSnackbar('حدث خطأ أثناء تحديد الموقع: ${e.toString()}');
      }
      return null;
    }
  }

  Future<void> updateCurrentLocation() async {
    try {
      if (!isMapReady.value || mapController == null) {
        showErrorSnackbar('الخريطة لم تُحمّل بعد. الرجاء الانتظار...');
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
      Get.snackbar(
        'الموقع',
        'تم تحديد موقعك الحالي',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error updating location: $e');
      if (e is LocationServiceDisabledException) {
        showErrorSnackbar('خدمة الموقع غير مفعّلة. فعّل GPS وحاول مرة أخرى.');
      } else if (e is PermissionDeniedException) {
        showErrorSnackbar('تم رفض صلاحية الموقع. فعّل الصلاحية من الإعدادات.');
      } else {
        showErrorSnackbar('حدث خطأ أثناء تحديث الموقع: ${e.toString()}');
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
      Get.snackbar('تحذير', 'يرجى التحقق من رقم الهاتف أولاً');
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

      Get.snackbar(
        'نجاح',
        'تم رفع الصور بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error in uploadImages: $e');
      Get.dialog(
        AlertDialog(
          title: const Text('خطأ'),
          content: const Text('فشل رفع الصور، يرجى المحاولة مجدداً'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    } finally {
      isUploadingImages.value = false;
      uploadProgress.value = 0.0;
    }
  }
}
