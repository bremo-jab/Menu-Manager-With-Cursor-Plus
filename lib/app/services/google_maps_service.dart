import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class GoogleMapsService extends GetxService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';
  static const String _apiKey =
      'AIzaSyCmOKp6Mt8JizbwjOfoKW9EDNfUsTs2T5c'; // استبدل بمفتاح API الخاص بك

  Future<GoogleMapsService> init() async {
    return this;
  }

  Future<Map<String, dynamic>?> getAddress(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?latlng=$lat,$lon&key=$_apiKey&language=ar'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final addressComponents = result['address_components'];

          Map<String, String> components = {};
          for (var component in addressComponents) {
            final types = component['types'] as List;
            if (types.contains('locality')) {
              components['city'] = component['long_name'];
            } else if (types.contains('administrative_area_level_1')) {
              components['state'] = component['long_name'];
            } else if (types.contains('country')) {
              components['country'] = component['long_name'];
            } else if (types.contains('postal_code')) {
              components['postcode'] = component['long_name'];
            } else if (types.contains('route')) {
              components['road'] = component['long_name'];
            } else if (types.contains('street_number')) {
              components['house_number'] = component['long_name'];
            } else if (types.contains('sublocality')) {
              components['suburb'] = component['long_name'];
            } else if (types.contains('neighborhood')) {
              components['neighbourhood'] = component['long_name'];
            }
          }

          return {
            'formatted': result['formatted_address'],
            'components': components,
          };
        }
      }
      return null;
    } catch (e) {
      print('Google Maps error: $e');
      return null;
    }
  }
}
