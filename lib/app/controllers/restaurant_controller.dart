import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_manager/app/data/models/restaurant_model.dart';
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
  final images = <File>[].obs;
  final markers = <Marker>{}.obs;
  final selectedPaymentMethods = <String>[].obs;
  final selectedServiceOptions = <String>[].obs;
  final wantsEmailUpdates = false.obs;

  late GoogleMapController mapController;
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
  final selectedCity = Rx<String?>(null);
  final selectedLatitude = Rx<double?>(null);
  final selectedLongitude = Rx<double?>(null);
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

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _requestLocationPermission();
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

    // Set initial city value
    if (palestinianCities.isNotEmpty) {
      selectedCity.value = palestinianCities.first;
      cityController.text = palestinianCities.first;
    }
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
      mapController.dispose();
    }
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    if (!Get.isRegistered<GoogleMapController>()) {
      Get.put(controller, permanent: true);
    }
    mapController = controller;
  }

  Future<String> getAddressFromPhoton(double lat, double lon) async {
    final url =
        Uri.parse('https://photon.komoot.io/reverse?lat=$lat&lon=$lon&lang=ar');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data['features'];
      if (features != null && features.isNotEmpty) {
        final props = features[0]['properties'];
        final street = props['street'] ?? '';
        final suburb = props['suburb'] ?? '';
        final city = props['city'] ?? '';
        final name = props['name'] ?? '';
        final addressParts = [street, suburb, city, name]
            .where((part) => part.isNotEmpty)
            .toList();
        return addressParts.join('، ');
      }
    }
    return '';
  }

  Future<String> getAddressFromNominatim(double lat, double lon) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&accept-language=ar');
    final headers = {
      'User-Agent': 'menu-app/1.0 (barhom.development@gmail.com)'
    };
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final address = data['address'];
      if (address != null) {
        final road = address['road'] ?? '';
        final suburb = address['suburb'] ?? '';
        final city = address['city'] ?? address['town'] ?? '';
        final state = address['state'] ?? '';
        final addressParts = [road, suburb, city, state]
            .where((part) => part.isNotEmpty)
            .toList();
        return addressParts.join('، ');
      }
    }
    return '';
  }

  Future<String> getAddress(double lat, double lon) async {
    try {
      final photonFuture = getAddressFromPhoton(lat, lon);
      final nominatimFuture = getAddressFromNominatim(lat, lon);

      final results = await Future.wait([photonFuture, nominatimFuture]);

      final photonParts = results[0].split('، ').map((e) => e.trim()).toSet();
      final nominatimParts =
          results[1].split('، ').map((e) => e.trim()).toSet();

      final mergedParts = <String>{
        ...photonParts,
        ...nominatimParts,
      }.where((part) => part.isNotEmpty).toList();

      final addressString = mergedParts.join('، ');

      // تحديث المدينة تلقائيًا بناءً على العنوان
      for (final city in palestinianCities) {
        if (addressString.contains(city)) {
          selectedCity.value = city;
          cityController.text = city;
          break;
        }
      }

      return addressString;
    } catch (e) {
      print('Error merging address: $e');
      return '';
    }
  }

  Future<void> onMapTap(LatLng position) async {
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('restaurant'),
        position: position,
      ),
    );

    if (!isAddressManuallyEdited) {
      final address = await getAddress(position.latitude, position.longitude);
      addressController.text = address;
    }

    selectedLatitude.value = position.latitude;
    selectedLongitude.value = position.longitude;
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
          images.add(File(image.path));
        }
      } else {
        final List<XFile> selectedImages = await picker.pickMultiImage();
        if (selectedImages.isNotEmpty) {
          images.addAll(selectedImages.map((image) => File(image.path)));
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

  void removeImage(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
    }
  }

  Future<void> saveRestaurant() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final userId =
          FirebaseAuth.instance.currentUser?.uid ?? const Uuid().v4();
      final folderName = 'restaurants/$userId';

      if (selectedRestaurantTypes.isEmpty) {
        Get.snackbar(
          'تنبيه',
          'يرجى اختيار نوع واحد على الأقل من أنواع المطعم',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }

      final uploadedLogoUrl = logoImage.value != null
          ? await CloudinaryService.uploadImage(logoImage.value!, folderName)
          : null;

      final uploadedImageUrls = <String>[];
      for (final image in images) {
        final url = await CloudinaryService.uploadImage(image, folderName);
        if (url != null) uploadedImageUrls.add(url);
      }

      final restaurantData = {
        'name': nameController.text,
        'description': descriptionController.text,
        'type': selectedRestaurantTypes,
        'address': addressController.text,
        'city': selectedCity.value,
        'phone': phoneController.text,
        'email': emailController.text,
        'website': websiteController.text,
        'facebook': facebookController.text,
        'instagram': instagramController.text,
        'twitter': twitterController.text,
        'whatsapp': whatsappController.text,
        'workingHours': _getWorkingHoursData(),
        'location': {
          'latitude': selectedLatitude.value,
          'longitude': selectedLongitude.value,
        },
        'logoUrl': uploadedLogoUrl,
        'imageUrls': uploadedImageUrls,
        'userId': userId,
        'wantsEmailUpdates': wantsEmailUpdates.value,
      };

      await _restaurantService.createRestaurant(
        restaurantData,
        logoImage.value,
        images,
      );

      Get.offAllNamed('/menu');
    } catch (e) {
      showErrorSnackbar('حدث خطأ أثناء حفظ بيانات المطعم');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, String>> _getWorkingHoursData() {
    return List.generate(
      7,
      (index) => {
        'day': weekDays[index],
        'open': workingHoursControllers[index][0].text,
        'close': workingHoursControllers[index][1].text,
      },
    );
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
            zoom: 15,
          ),
        ),
      );

      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('restaurant'),
          position: latLng,
        ),
      );

      if (!isAddressManuallyEdited) {
        final address = await getAddress(position.latitude, position.longitude);
        addressController.text = address;
      }

      selectedLatitude.value = position.latitude;
      selectedLongitude.value = position.longitude;
    } catch (e) {
      print('Error getting location: $e');
      showErrorSnackbar('فشل في الحصول على الموقع الحالي');
    }
  }

  void onCameraMove(CameraPosition position) {
    isMapMoved.value = true;
  }
}
