import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/kitchen_listing.dart';

class ListingsApi {
  final String baseUrl = 'http://localhost:8000/api/v1';

  Future<List<KitchenListing>> fetchListings({
    String? city,
    String? type,
    double? minPrice,
    double? maxPrice,
    bool? isFeatured,
    String? ownerId,
    String? token,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};

      if (city != null && city.isNotEmpty && city != 'الكل') {
        queryParams['city'] = city;
      }

      if (type != null && type.isNotEmpty && type != 'الكل') {
        queryParams['type'] = type;
      }

      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }

      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }

      if (isFeatured != null) {
        queryParams['is_featured'] = isFeatured.toString();
      }

      if (ownerId != null) {
        queryParams['owner_id'] = ownerId;
      }

      // Build URI
      final uri = Uri.parse('$baseUrl/listings').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      // Build headers
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Make request
      final response = await http.get(uri, headers: headers.isNotEmpty ? headers : null);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => KitchenListing.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'فشل في تحميل المطابخ. رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  Future<KitchenListing> createListing({
    required String title,
    required String description,
    required double price,
    required String city,
    required String type,
    required String material,
    double? lengthM,
    double? widthM,
    double? heightM,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/listings');

      final body = {
        'title': title,
        'description': description,
        'price': price,
        'city': city,
        'type': type,
        'material': material,
        if (lengthM != null) 'length_m': lengthM,
        if (widthM != null) 'width_m': widthM,
        if (heightM != null) 'height_m': heightM,
      };

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return KitchenListing.fromJson(jsonData);
      } else {
        throw Exception(
          'فشل في إضافة المطبخ. رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  Future<String> generateDescription({
    required String title,
    required String city,
    required String type,
    required String material,
    double? price,
    String? notes,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/ai/generate-description');

      final body = {
        'title': title,
        'city': city,
        'type': type,
        'material': material,
        if (price != null) 'price': price,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['description'] as String;
      } else {
        throw Exception(
          'فشل في توليد الوصف. رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }
}
