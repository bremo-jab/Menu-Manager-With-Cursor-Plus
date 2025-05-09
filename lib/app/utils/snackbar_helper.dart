import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackbar(
  String title,
  String message, {
  SnackPosition position = SnackPosition.BOTTOM,
  Duration duration = const Duration(seconds: 3),
  bool isDismissible = true,
  Color backgroundColor = Colors.orange,
  Color textColor = Colors.white,
  double borderRadius = 8,
  EdgeInsets margin = const EdgeInsets.all(8),
}) {
  Get.snackbar(
    title,
    message,
    snackPosition: position,
    duration: duration,
    isDismissible: isDismissible,
    backgroundColor: backgroundColor,
    colorText: textColor,
    borderRadius: borderRadius,
    margin: margin,
    forwardAnimationCurve: Curves.easeOutBack,
  );
}
