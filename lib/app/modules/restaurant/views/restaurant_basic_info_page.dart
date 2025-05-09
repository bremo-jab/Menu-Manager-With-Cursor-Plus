import 'package:flutter/material.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';
import 'package:menu_manager/app/widgets/restaurant_name_field.dart';

class RestaurantBasicInfoPage extends StatelessWidget {
  final RestaurantController controller;

  const RestaurantBasicInfoPage({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: RestaurantNameField(controller: controller.nameController),
    );
  }
}
