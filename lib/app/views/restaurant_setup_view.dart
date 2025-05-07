import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_manager/app/controllers/restaurant_controller.dart';

class RestaurantSetupView extends StatefulWidget {
  const RestaurantSetupView({Key? key}) : super(key: key);

  @override
  _RestaurantSetupViewState createState() => _RestaurantSetupViewState();
}

class _RestaurantSetupViewState extends State<RestaurantSetupView> {
  final RestaurantController controller = Get.find<RestaurantController>();

  @override
  Widget build(BuildContext context) {
    // ... (existing code)

    return Scaffold(
      // ... (existing code)

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ... (existing code)

              if (controller.currentStep.value == 4) ...[
                const Text(
                  'ساعات العمل',
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
                      children: List.generate(7, (index) {
                        final dayNames = [
                          'الأحد',
                          'الإثنين',
                          'الثلاثاء',
                          'الأربعاء',
                          'الخميس',
                          'الجمعة',
                          'السبت'
                        ];
                        return Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  dayNames[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    TextButton.icon(
                                      onPressed: () async {
                                        final TimeOfDay? picked =
                                            await showTimePicker(
                                          context: context,
                                          initialTime:
                                              controller.workingHours[index] ??
                                                  TimeOfDay.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                timePickerTheme:
                                                    TimePickerThemeData(
                                                  backgroundColor: Colors.white,
                                                  hourMinuteShape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (picked != null) {
                                          controller.workingHours[index] =
                                              picked;
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.access_time,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                      label: Text(
                                        controller.workingHours[index]
                                                ?.format(context) ??
                                            'من',
                                        style: TextStyle(
                                          color:
                                              controller.workingHours[index] !=
                                                      null
                                                  ? Colors.black
                                                  : Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () async {
                                        final TimeOfDay? picked =
                                            await showTimePicker(
                                          context: context,
                                          initialTime:
                                              controller.closingHours[index] ??
                                                  TimeOfDay.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                timePickerTheme:
                                                    TimePickerThemeData(
                                                  backgroundColor: Colors.white,
                                                  hourMinuteShape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (picked != null) {
                                          controller.closingHours[index] =
                                              picked;
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.access_time,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                      label: Text(
                                        controller.closingHours[index]
                                                ?.format(context) ??
                                            'إلى',
                                        style: TextStyle(
                                          color:
                                              controller.closingHours[index] !=
                                                      null
                                                  ? Colors.black
                                                  : Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (index < 6) ...[
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                            ],
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
