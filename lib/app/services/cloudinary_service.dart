import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:menu_manager/app/models/cloudinary_image.dart';

class CloudinaryService {
  static const cloudName = 'dsqt1hjnd'; // ضع اسم حسابك على Cloudinary
  static const uploadPreset = 'Menu App'; // أو احذف هذا واستخدم API Key وSecret
  static const apiKey = 'your_api_key';
  static const apiSecret = 'your_api_secret';

  static Future<CloudinaryImage?> uploadImage(
      File image, String folderName) async {
    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folderName
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      return CloudinaryImage(
        url: data['secure_url'],
        publicId: data['public_id'],
      );
    } else {
      print('❌ Cloudinary Upload Failed: ${response.statusCode}');
      return null;
    }
  }

  static Future<void> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = _generateSignature(publicId, timestamp);

      final response = await http.post(
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy'),
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': apiKey,
          'signature': signature,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete image: ${response.body}');
      }
    } catch (e) {
      print('Error deleting image from Cloudinary: $e');
      rethrow;
    }
  }

  static String _generateSignature(String publicId, int timestamp) {
    final params = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
    final bytes = utf8.encode(params);
    final hash = sha1.convert(bytes);
    return hash.toString();
  }
}
