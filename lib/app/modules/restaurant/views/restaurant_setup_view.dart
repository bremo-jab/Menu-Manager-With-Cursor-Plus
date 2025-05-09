import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';
import 'package:menu_manager/app/modules/restaurant/views/restaurant_images_page.dart';
import 'package:menu_manager/app/modules/restaurant/views/restaurant_basic_info_page.dart';
import 'package:menu_manager/app/modules/restaurant/views/restaurant_type_page.dart';
import 'package:menu_manager/app/modules/restaurant/views/restaurant_city_page.dart';
import 'package:menu_manager/app/modules/restaurant/views/restaurant_location_page.dart';
import 'package:menu_manager/app/modules/restaurant/views/restaurant_phone_page.dart';

class RestaurantSetupView extends StatelessWidget {
  const RestaurantSetupView({super.key});

  String _getPageTitle(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return 'صور المطعم';
      case 1:
        return 'معلومات المطعم';
      case 2:
        return 'نوع المطعم';
      case 3:
        return 'المدينة';
      case 4:
        return 'موقع المطعم';
      case 5:
        return 'رقم الهاتف';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RestaurantController());

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Obx(() {
                  return LinearProgressIndicator(
                    value: (controller.currentPage.value + 1) /
                        controller.totalSteps.value,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 12,
                  );
                }),
              ),
            ),
            Obx(() => Text(
                  _getPageTitle(controller.currentPage.value),
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 16),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  RestaurantImagesPage(controller: controller),
                  RestaurantBasicInfoPage(controller: controller),
                  RestaurantTypePage(controller: controller),
                  RestaurantCityPage(controller: controller),
                  RestaurantLocationPage(controller: controller),
                  RestaurantPhonePage(controller: controller),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    if (controller.currentPage.value == 0) {
                      return const SizedBox.shrink();
                    }
                    return ElevatedButton(
                      onPressed: controller.goToPreviousPage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('السابق'),
                    );
                  }),
                  Obx(() {
                    if (controller.currentPage.value ==
                        controller.totalSteps.value - 1) {
                      return const SizedBox.shrink();
                    }
                    return ElevatedButton(
                      onPressed: () {
                        if (controller.validateCurrentPage()) {
                          controller.goToNextPage();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('التالي'),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
