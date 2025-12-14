import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// خدمة المصادقة والإدارة للـ Admin Panel
class AdminService {
  static const String baseUrl = 'https://souqmatbakh.com/api/v1';
  static const String authEndpoint = '$baseUrl/auth/login';
  static const String quotesEndpoint = '$baseUrl/quotes/';
  static const String statsEndpoint = '$baseUrl/quotes/stats';

  static final _storage = FlutterSecureStorage();
  static const _tokenKey = 'admin_access_token';

  /// تسجيل دخول المسؤول
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(authEndpoint),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {'username': email, 'password': password},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        // حفظ التوكن
        await _storage.write(key: _tokenKey, value: token);

        return data;
      } else if (response.statusCode == 401) {
        throw AdminAuthException('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      } else {
        throw AdminAuthException('فشل تسجيل الدخول');
      }
    } catch (e) {
      if (e is AdminAuthException) rethrow;
      throw AdminAuthException('خطأ في الاتصال بالسيرفر');
    }
  }

  /// تسجيل الخروج
  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  /// التحقق من تسجيل الدخول
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// الحصول على التوكن
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// جلب جميع طلبات الأسعار
  static Future<List<Map<String, dynamic>>> fetchAllQuotes({
    String? status,
    String? style,
    String? city,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw AdminAuthException('غير مسجل دخول');

      final queryParams = <String, String>{'skip': skip.toString(), 'limit': limit.toString()};
      if (status != null) queryParams['status'] = status;
      if (style != null) queryParams['style'] = style;
      if (city != null) queryParams['city'] = city;

      final uri = Uri.parse(quotesEndpoint).replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['items'] ?? []);
      } else if (response.statusCode == 401) {
        await logout();
        throw AdminAuthException('انتهت صلاحية الجلسة');
      } else {
        throw AdminApiException('فشل جلب البيانات');
      }
    } catch (e) {
      if (e is AdminAuthException || e is AdminApiException) rethrow;
      throw AdminApiException('خطأ في الاتصال');
    }
  }

  /// جلب تفاصيل طلب محدد
  static Future<Map<String, dynamic>> fetchQuoteById(int id) async {
    try {
      final token = await getToken();
      if (token == null) throw AdminAuthException('غير مسجل دخول');

      final response = await http
          .get(
            Uri.parse('$quotesEndpoint$id'),
            headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw AdminApiException('الطلب غير موجود');
      } else if (response.statusCode == 401) {
        await logout();
        throw AdminAuthException('انتهت صلاحية الجلسة');
      } else {
        throw AdminApiException('فشل جلب البيانات');
      }
    } catch (e) {
      if (e is AdminAuthException || e is AdminApiException) rethrow;
      throw AdminApiException('خطأ في الاتصال');
    }
  }

  /// تحديث حالة الطلب
  static Future<Map<String, dynamic>> updateQuoteStatus({
    required int id,
    required String status,
    String? adminNotes,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw AdminAuthException('غير مسجل دخول');

      final body = <String, dynamic>{'status': status};
      if (adminNotes != null) body['admin_notes'] = adminNotes;

      final response = await http
          .patch(
            Uri.parse('$quotesEndpoint$id/status'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw AdminApiException('الطلب غير موجود');
      } else if (response.statusCode == 401) {
        await logout();
        throw AdminAuthException('انتهت صلاحية الجلسة');
      } else {
        throw AdminApiException('فشل تحديث الحالة');
      }
    } catch (e) {
      if (e is AdminAuthException || e is AdminApiException) rethrow;
      throw AdminApiException('خطأ في الاتصال');
    }
  }

  /// حذف طلب
  static Future<void> deleteQuote(int id) async {
    try {
      final token = await getToken();
      if (token == null) throw AdminAuthException('غير مسجل دخول');

      final response = await http
          .delete(Uri.parse('$quotesEndpoint$id'), headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        await logout();
        throw AdminAuthException('انتهت صلاحية الجلسة');
      } else if (response.statusCode != 204 && response.statusCode != 200) {
        throw AdminApiException('فشل حذف الطلب');
      }
    } catch (e) {
      if (e is AdminAuthException || e is AdminApiException) rethrow;
      throw AdminApiException('خطأ في الاتصال');
    }
  }

  /// جلب الإحصائيات
  static Future<Map<String, dynamic>> fetchStats() async {
    try {
      final token = await getToken();
      if (token == null) throw AdminAuthException('غير مسجل دخول');

      final response = await http
          .get(
            Uri.parse(statsEndpoint),
            headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await logout();
        throw AdminAuthException('انتهت صلاحية الجلسة');
      } else {
        throw AdminApiException('فشل جلب الإحصائيات');
      }
    } catch (e) {
      if (e is AdminAuthException || e is AdminApiException) rethrow;
      throw AdminApiException('خطأ في الاتصال');
    }
  }
}

/// استثناء مصادقة Admin
class AdminAuthException implements Exception {
  final String message;
  AdminAuthException(this.message);

  @override
  String toString() => message;
}

/// استثناء API Admin
class AdminApiException implements Exception {
  final String message;
  AdminApiException(this.message);

  @override
  String toString() => message;
}
