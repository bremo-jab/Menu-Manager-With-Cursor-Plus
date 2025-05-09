import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:menu_manager/app/services/opencage_service.dart';
import 'package:menu_manager/app/services/google_maps_service.dart';

class MapLocationPicker extends StatefulWidget {
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
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late GoogleMapController _mapController;
  LatLng _currentCameraPosition =
      const LatLng(31.9522, 35.2332); // موقع افتراضي في فلسطين
  String _currentAddress = '';

  Future<String> _getAddressFromLatLng(LatLng position) async {
    try {
      final openCageService = Get.find<OpenCageService>();
      final googleMapsService = Get.find<GoogleMapsService>();

      final openCageResult = await openCageService.getAddress(
          position.latitude, position.longitude);
      final googleMapsResult = await googleMapsService.getAddress(
          position.latitude, position.longitude);

      String? address;
      if (openCageResult != null) {
        address = openCageResult['formatted'] as String?;
      }
      if (!_isValidArabicAddress(address) && googleMapsResult != null) {
        address = googleMapsResult['formatted'] as String?;
      }
      if (!_isValidArabicAddress(address)) {
        return 'لم يتم العثور على عنوان';
      }
      return _cleanArabicAddress(address!);
    } catch (e) {
      print('Error getting address from services: $e');
      return 'لم يتم العثور على عنوان';
    }
  }

  bool _isValidArabicAddress(String? address) {
    if (address == null) return false;
    if (address.toLowerCase().contains('unnamed') ||
        address.toLowerCase().contains('unknown') ||
        address.toLowerCase().contains('null')) {
      return false;
    }
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(address);
  }

  String _cleanArabicAddress(String address) {
    List<String> parts = address.split(',').map((e) => e.trim()).toList();
    final arabicRegex = RegExp(r'^[\u0600-\u06FF\s0-9]+$');
    List<String> cleaned = parts.where((part) {
      return arabicRegex.hasMatch(part) &&
          !part.toLowerCase().contains('unnamed') &&
          !part.toLowerCase().contains('unknown') &&
          !part.toLowerCase().contains('null');
    }).toList();
    return cleaned.join('، ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentCameraPosition,
                  zoom: 15,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                onCameraMove: (position) {
                  _currentCameraPosition = position.target;
                },
                onCameraIdle: () async {
                  final address =
                      await _getAddressFromLatLng(_currentCameraPosition);
                  setState(() {
                    _currentAddress = address;
                  });
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
              ),
              const Center(
                child: Icon(Icons.location_pin, size: 40, color: Colors.red),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'العنوان المحدد:',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentAddress,
                style: GoogleFonts.cairo(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'latitude': _currentCameraPosition.latitude,
                        'longitude': _currentCameraPosition.longitude,
                        'address': _currentAddress,
                      });
                    },
                    child: const Text('تأكيد الموقع'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
