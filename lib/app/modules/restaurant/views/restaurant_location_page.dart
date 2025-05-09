import 'package:flutter/material.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';
import 'package:menu_manager/app/modules/restaurant/views/full_map_location_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

class RestaurantLocationPage extends StatelessWidget {
  final RestaurantController controller;

  const RestaurantLocationPage({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'موقع المطعم',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Get.to(
                        () => FullMapLocationView(
                          controller: controller,
                          initialPosition: LatLng(
                            controller.selectedLatitude.value,
                            controller.selectedLongitude.value,
                          ),
                        ),
                      );

                      if (result != null) {
                        controller.selectedLatitude.value = result['latitude'];
                        controller.selectedLongitude.value =
                            result['longitude'];
                        controller.addressController.text = result['address'];
                      }
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('تحديد الموقع من الخريطة'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.addressController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'يرجى التأكد من صحة العنوان وتعديله إن لزم',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final lat = controller.selectedLatitude.value;
                    final lng = controller.selectedLongitude.value;
                    return Text(
                      'إحداثيات الموقع: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
