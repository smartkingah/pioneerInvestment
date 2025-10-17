import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static const String cloudName = 'dy523yrlh'; // your Cloudinary cloud name
  static const String uploadPreset =
      'unsigned_preset_v1'; // your unsigned preset

  /// Upload image (File) for mobile/desktop
  static Future<String?> uploadImage(File file) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      final mimeParts = mimeType.split('/');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            contentType: MediaType(mimeParts[0], mimeParts[1]),
          ),
        );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        return body['secure_url'] as String?;
      } else {
        print(
          'Cloudinary upload failed: ${response.statusCode} ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload image (Uint8List) for web
  static Future<String?> uploadWebImage(Uint8List bytes) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'upload.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        return body['secure_url'] as String?;
      } else {
        print(
          'Cloudinary upload failed (web): ${response.statusCode} ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error uploading web image: $e');
      return null;
    }
  }
}
