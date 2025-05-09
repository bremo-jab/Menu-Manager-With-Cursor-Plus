import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class OpenCageService extends GetxService {
  static const String _baseUrl = 'https://api.opencagedata.com/geocode/v1/json';
  static const String _apiKey =
      '6c1ce51c1d9f4835a0957a8bec96fd3a'; // استبدل بمفتاح API الخاص بك

  Future<OpenCageService> init() async {
    return this;
  }

  Future<Map<String, dynamic>?> getAddress(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl?q=$lat+$lon&key=$_apiKey&language=ar&no_annotations=1'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final components = result['components'];

          return {
            'formatted': result['formatted'],
            'components': {
              'city': components['city'] ??
                  components['town'] ??
                  components['village'],
              'state': components['state'],
              'country': components['country'],
              'postcode': components['postcode'],
              'road': components['road'],
              'house_number': components['house_number'],
              'suburb': components['suburb'],
              'neighbourhood': components['neighbourhood'],
            },
          };
        }
      }
      return null;
    } catch (e) {
      print('OpenCage error: $e');
      return null;
    }
  }
}
