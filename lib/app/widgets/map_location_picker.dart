import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

class MapLocationPicker extends StatelessWidget {
  final Set<Marker> markers;
  final void Function(LatLng) onTap;
  final void Function(CameraPosition) onCameraMove;
  final VoidCallback onConfirm;
  final VoidCallback onGetCurrentLocation;
  final RxBool isMapMoved;
  final RxDouble? lat;
  final RxDouble? lon;
  final void Function(GoogleMapController) onMapCreated;

  const MapLocationPicker({
    super.key,
    required this.markers,
    required this.onTap,
    required this.onCameraMove,
    required this.onConfirm,
    required this.onGetCurrentLocation,
    required this.isMapMoved,
    required this.lat,
    required this.lon,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'الموقع الجغرافي',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 450,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: const LatLng(24.7136, 46.6753),
                    zoom: 15,
                  ),
                  onMapCreated: onMapCreated,
                  onTap: onTap,
                  onCameraMove: onCameraMove,
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  liteModeEnabled: false,
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer())
                  },
                ),
              ),
              Obx(() => isMapMoved.value
                  ? Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: onGetCurrentLocation,
                        child: const Icon(Icons.my_location),
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onConfirm,
          icon: const Icon(Icons.check_circle),
          label: Text(
            'تأكيد الموقع',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (lat?.value != null && lon?.value != null) {
            return Row(
              children: [
                Expanded(
                  child: Text(
                    'الإحداثيات: ${lat!.value.toStringAsFixed(5)}, ${lon!.value.toStringAsFixed(5)}',
                    style: GoogleFonts.cairo(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: '${lat!.value},${lon!.value}'));
                    Get.snackbar('تم النسخ', 'تم نسخ الإحداثيات إلى الحافظة');
                  },
                )
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
