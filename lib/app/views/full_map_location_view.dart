import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menu_manager/app/services/opencage_service.dart';
import 'package:menu_manager/app/services/google_maps_service.dart';

class FullMapLocationView extends StatefulWidget {
  final LatLng initialPosition;

  const FullMapLocationView({
    super.key,
    required this.initialPosition,
  });

  @override
  State<FullMapLocationView> createState() => _FullMapLocationViewState();
}

class _FullMapLocationViewState extends State<FullMapLocationView> {
  late GoogleMapController _mapController;
  LatLng _currentPosition =
      const LatLng(31.9522, 35.2332); // موقع افتراضي في فلسطين
  String _currentAddress = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
    _getAddressFromLatLng(_currentPosition);
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isLoading = true);
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
    } finally {
      setState(() => _isLoading = false);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اختر موقع المطعم',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onCameraMove: (position) {
              _currentPosition = position.target;
            },
            onCameraIdle: () async {
              final address = await _getAddressFromLatLng(_currentPosition);
              setState(() {
                _currentAddress = address;
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId('restaurant'),
                position: _currentPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure),
              ),
            },
          ),
          const Center(
            child: Icon(Icons.location_pin, size: 40, color: Colors.red),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'العنوان المحدد:',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Text(
                      _currentAddress,
                      style: GoogleFonts.cairo(fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(result: {
                          'lat': _currentPosition.latitude,
                          'lon': _currentPosition.longitude,
                          'address': _currentAddress,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'تأكيد الموقع',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
