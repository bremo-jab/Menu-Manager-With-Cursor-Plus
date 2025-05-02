import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showErrorSnackbar(String message) {
  Get.snackbar(
    '',
    '',
    titleText: Row(
      children: [
        const Icon(Icons.info_outline, color: Colors.white),
        const SizedBox(width: 8),
        const Text(
          'إشعار',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
    messageText: Text(
      message,
      style: const TextStyle(color: Colors.white, fontSize: 14),
    ),
    backgroundColor: Colors.redAccent,
    snackPosition: SnackPosition.BOTTOM,
    borderRadius: 12,
    margin: const EdgeInsets.all(12),
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 300),
  );
}

void showInfoSnackbar(String message) {
  Get.snackbar(
    '',
    '',
    titleText: Row(
      children: [
        const Icon(Icons.info_outline, color: Colors.white),
        const SizedBox(width: 8),
        const Text(
          'معلومات',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
    messageText: Text(
      message,
      style: const TextStyle(color: Colors.white, fontSize: 14),
    ),
    backgroundColor: Colors.blue,
    snackPosition: SnackPosition.BOTTOM,
    borderRadius: 12,
    margin: const EdgeInsets.all(12),
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 300),
  );
}

void showSuccessSnackbar(String title, String message) {
  Get.snackbar(
    '',
    '',
    titleText: Row(
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.white),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
    messageText: Text(
      message,
      style: const TextStyle(color: Colors.white, fontSize: 14),
    ),
    backgroundColor: Colors.green,
    snackPosition: SnackPosition.BOTTOM,
    borderRadius: 12,
    margin: const EdgeInsets.all(12),
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 300),
  );
}
