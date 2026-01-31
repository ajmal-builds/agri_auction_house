import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ImageUploadService {
  static const String _apiKey = "cc4fe1e780dacffea17c720c81692abb";

  static Future<String> uploadImage(XFile image) async {
    final uri = Uri.parse(
      "https://api.imgbb.com/1/upload?key=$_apiKey",
    );

    Uint8List bytes = await image.readAsBytes();
    String base64Image = base64Encode(bytes);

    final response = await http.post(
      uri,
      body: {
        'image': base64Image,
      },
    );

    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      return data['data']['url'];
    } else {
      throw Exception("Image upload failed");
    }
  }
}
