import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const cloudName = 'dsqt1hjnd'; // ضع اسم حسابك على Cloudinary
  static const uploadPreset =
      'Menu App'; // أو احذف هذا واستخدم API Key وSecret

  static Future<String?> uploadImage(File image, String folderName) async {
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
      return data['secure_url'];
    } else {
      print('❌ Cloudinary Upload Failed: ${response.statusCode}');
      return null;
    }
  }
}
