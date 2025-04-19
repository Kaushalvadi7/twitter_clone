import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'dee7ivwto';
  static const String uploadPreset = 'twitter_clone';
  static Future<String?> uploadImageToCloudinary(File image) async {
try {
  final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  final request = http.MultipartRequest('POST', uri)
  ..fields['upload_preset'] = uploadPreset
  ..files.add(await http.MultipartFile.fromPath('file', image.path));

  final response = await request.send();
  final resStr = await response.stream.bytesToString();

  if (response.statusCode == 200) {
  final data = json.decode(resStr);
  return data['secure_url'];
  } else {
  print('Cloudinary Upload Failed [${response.statusCode}]: $resStr');
  return null;
  }
  } catch (e) {
  print('Cloudinary Upload Exception: $e');
  return null;
  }
  }
}
