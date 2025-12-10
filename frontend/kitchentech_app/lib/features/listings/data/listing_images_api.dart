import 'dart:typed_data';

import 'package:http/http.dart' as http;

class ListingImagesApi {
  final String baseUrl = 'http://localhost:8000/api/v1';

  /// Upload multiple images for a listing
  Future<void> uploadImages({
    required String listingId,
    required List<Uint8List> filesBytes,
    required List<String> fileNames,
    required String token,
  }) async {
    if (filesBytes.isEmpty) {
      return;
    }

    final uri = Uri.parse('$baseUrl/listings/$listingId/images');
    final request = http.MultipartRequest('POST', uri);

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Add all image files
    for (int i = 0; i < filesBytes.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          filesBytes[i],
          filename: fileNames[i],
        ),
      );
    }

    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'فشل في رفع الصور. رمز الخطأ: ${response.statusCode}',
      );
    }
  }

  /// Get all images for a listing
  Future<List<Map<String, dynamic>>> getImages({
    required String listingId,
  }) async {
    final uri = Uri.parse('$baseUrl/listings/$listingId/images');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // Parse response as list
      return List<Map<String, dynamic>>.from(
        (response.body as List).map((x) => Map<String, dynamic>.from(x)),
      );
    } else {
      throw Exception(
        'فشل في تحميل الصور. رمز الخطأ: ${response.statusCode}',
      );
    }
  }

  /// Delete an image
  Future<void> deleteImage({
    required String listingId,
    required String imageId,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/listings/$listingId/images/$imageId');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'فشل في حذف الصورة. رمز الخطأ: ${response.statusCode}',
      );
    }
  }
}
