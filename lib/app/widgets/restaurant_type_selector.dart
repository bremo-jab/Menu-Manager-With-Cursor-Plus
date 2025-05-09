import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantTypeSelector extends StatelessWidget {
  final RxList<String> selectedTypes;
  final List<String> allTypes;

  const RestaurantTypeSelector({
    super.key,
    required this.selectedTypes,
    required this.allTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3.5,
          children: allTypes.map((type) {
            final isSelected = selectedTypes.contains(type);
            return GestureDetector(
              onTap: () {
                if (isSelected) {
                  selectedTypes.remove(type);
                } else {
                  selectedTypes.add(type);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  type,
                  style: GoogleFonts.cairo(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }
}
