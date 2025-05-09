import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:menu_manager/app/routes/app_pages.dart';
import 'package:menu_manager/app/theme/app_theme.dart';
import 'package:menu_manager/app/bindings/initial_binding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_manager/app/services/opencage_service.dart';
import 'package:menu_manager/app/services/google_maps_service.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Get.putAsync(() => OpenCageService().init());
  await Get.putAsync(() => GoogleMapsService().init());
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  String initialRoute = Routes.LOGIN;

  if (isLoggedIn) {
    final userId = prefs.getString('user_id');
    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['restaurantId'] != null) {
          initialRoute = Routes.MENU;
        } else {
          initialRoute = Routes.RESTAURANT_SETUP;
        }
      } else {
        initialRoute = Routes.RESTAURANT_SETUP;
      }
    }
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Menu Manager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ar', 'SA'),
      debugShowCheckedModeBanner: false,
    );
  }
}
