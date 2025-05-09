import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class RestaurantImagesSection extends StatelessWidget {
  final RestaurantController controller;

  const RestaurantImagesSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // شعار المطعم
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'شعار المطعم',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Stack(
                    children: [
                      Obx(() => GestureDetector(
                            onTap: controller.pickLogo,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                              backgroundImage:
                                  controller.logoImage.value != null
                                      ? FileImage(controller.logoImage.value!)
                                      : null,
                              child: controller.logoImage.value == null
                                  ? const Icon(Icons.restaurant, size: 40)
                                  : null,
                            ),
                          )),
                      Obx(() => controller.logoImage.value != null
                          ? Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: controller.deleteLogo,
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: controller.pickLogo,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('إضافة الشعار'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // صور المطعم
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'صور المطعم',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final allImages = <Widget>[];

                  // إضافة الصور المحلية
                  for (var i = 0; i < controller.images.length; i++) {
                    allImages.add(
                      Stack(
                        key: ValueKey('local_$i'),
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(controller.images[i]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => controller.removeImage(i),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // إضافة الصور السحابية
                  for (var i = 0; i < controller.cloudinaryImages.length; i++) {
                    allImages.add(
                      Stack(
                        key: ValueKey('cloud_$i'),
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(
                                    controller.cloudinaryImages[i].url),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => controller
                                  .removeImage(i + controller.images.length),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (allImages.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لا توجد صور',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ReorderableGridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: allImages,
                    onReorder: (oldIndex, newIndex) {
                      controller.reorderImages(oldIndex, newIndex);
                    },
                  );
                }),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: controller.pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('إضافة صور'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
