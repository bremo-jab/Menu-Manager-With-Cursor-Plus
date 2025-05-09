import 'package:flutter/material.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';
import 'package:menu_manager/app/widgets/restaurant_images_section.dart';

class RestaurantImagesPage extends StatelessWidget {
  final RestaurantController controller;

  const RestaurantImagesPage({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: RestaurantImagesSection(controller: controller),
    );
  }
}
