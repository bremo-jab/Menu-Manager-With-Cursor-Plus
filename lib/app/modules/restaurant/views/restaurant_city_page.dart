import 'package:flutter/material.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';
import 'package:menu_manager/app/widgets/city_selector_field.dart';

class RestaurantCityPage extends StatelessWidget {
  final RestaurantController controller;

  const RestaurantCityPage({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: CitySelectorField(controller: controller),
    );
  }
}
