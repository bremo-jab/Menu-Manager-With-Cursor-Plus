import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/login_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'إدارة المطعم',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
      ),
      debugShowCheckedModeBanner: false,
      home: LoginView(),
    );
  }
}
