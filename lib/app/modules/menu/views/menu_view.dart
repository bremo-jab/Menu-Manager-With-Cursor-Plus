import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_manager/app/controllers/menu_controller.dart' as menu;
import 'package:menu_manager/app/controllers/auth_controller.dart';
import 'package:menu_manager/app/widgets/custom_text_field.dart';

class MenuView extends GetView<menu.MenuController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القائمة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.dialog(
              AlertDialog(
                title: const Text('إضافة فئة جديدة'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: controller.categoryNameController,
                      label: 'اسم الفئة',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال اسم الفئة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.categoryDescriptionController,
                      label: 'وصف الفئة',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال وصف الفئة';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: controller.addCategory,
                    child: const Text('إضافة'),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => Get.find<AuthController>().signOut(),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return Card(
                    child: ExpansionTile(
                      title: Text(category.name),
                      subtitle: Text(category.description),
                      children: [
                        ...controller.items
                            .where((item) => item.categoryId == category.id)
                            .map(
                              (item) => ListTile(
                                leading: Image.network(
                                  item.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(item.name),
                                subtitle: Text(item.description),
                                trailing: Text(
                                  '${item.price} ريال',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () => Get.dialog(
                                  AlertDialog(
                                    title: const Text('تعديل العنصر'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomTextField(
                                          controller:
                                              controller.itemNameController,
                                          label: 'اسم العنصر',
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'الرجاء إدخال اسم العنصر';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        CustomTextField(
                                          controller: controller
                                              .itemDescriptionController,
                                          label: 'وصف العنصر',
                                          maxLines: 3,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'الرجاء إدخال وصف العنصر';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        CustomTextField(
                                          controller:
                                              controller.itemPriceController,
                                          label: 'السعر',
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'الرجاء إدخال السعر';
                                            }
                                            if (double.tryParse(value) ==
                                                null) {
                                              return 'الرجاء إدخال رقم صحيح';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('إلغاء'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            controller.updateItem(item.id),
                                        child: const Text('حفظ'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ListTile(
                          leading: const Icon(Icons.add),
                          title: const Text('إضافة عنصر جديد'),
                          onTap: () => Get.dialog(
                            AlertDialog(
                              title: const Text('إضافة عنصر جديد'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomTextField(
                                    controller: controller.itemNameController,
                                    label: 'اسم العنصر',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'الرجاء إدخال اسم العنصر';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    controller:
                                        controller.itemDescriptionController,
                                    label: 'وصف العنصر',
                                    maxLines: 3,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'الرجاء إدخال وصف العنصر';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    controller: controller.itemPriceController,
                                    label: 'السعر',
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'الرجاء إدخال السعر';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'الرجاء إدخال رقم صحيح';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('إلغاء'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      controller.addItem(category.id),
                                  child: const Text('إضافة'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
