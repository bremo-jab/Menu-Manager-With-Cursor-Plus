import 'package:flutter/material.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';
import 'package:menu_manager/app/widgets/restaurant_type_selector.dart';

class RestaurantTypePage extends StatelessWidget {
  final RestaurantController controller;

  const RestaurantTypePage({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: RestaurantTypeSelector(
        selectedTypes: controller.selectedRestaurantTypes,
        allTypes: controller.restaurantTypes,
      ),
    );
  }
}
