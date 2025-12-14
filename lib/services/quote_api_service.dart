import 'dart:convert';

import 'package:http/http.dart' as http;

/// خدمة API لطلبات عروض الأسعار
class QuoteApiService {
  static const String baseUrl = 'https://souqmatbakh.com/api/v1';
  static const String quotesEndpoint = '$baseUrl/quotes/';

  /// إرسال طلب عرض سعر جديد
  /// 
  /// Parameters:
  /// - [style]: نوع المطبخ (modern, classic, wood, aluminum)
  /// - [city]: المدينة
  /// - [phone]: رقم الجوال (05xxxxxxxx)
  /// 
  /// Returns:
  /// - Map containing quote request details including id
  /// 
  /// Throws:
  /// - [QuoteApiException] في حالة فشل الطلب
  static Future<Map<String, dynamic>> submitQuoteRequest({
    required String style,
    required String city,
    required String phone,
  }) async {
    try {
      // تحضير البيانات
      final requestData = {
        'style': style,
        'city': city,
        'phone': phone,
      };

      // إرسال الطلب
      final response = await http.post(
        Uri.parse(quotesEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw QuoteApiException(
            'انتهى الوقت المحدد للطلب. تحقق من اتصال الإنترنت',
            errorCode: 'TIMEOUT',
          );
        },
      );

      // معالجة الاستجابة
      if (response.statusCode == 201) {
        // نجاح الإنشاء
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 429) {
        // تجاوز حد الطلبات
        throw QuoteApiException(
          'تم تجاوز الحد المسموح من الطلبات. الرجاء المحاولة بعد دقيقة',
          errorCode: 'RATE_LIMIT',
          statusCode: 429,
        );
      } else if (response.statusCode == 400) {
        // بيانات غير صحيحة
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['detail'] ?? 'البيانات المدخلة غير صحيحة';
        throw QuoteApiException(
          errorMessage,
          errorCode: 'VALIDATION_ERROR',
          statusCode: 400,
        );
      } else if (response.statusCode >= 500) {
        // خطأ في السيرفر
        throw QuoteApiException(
          'خطأ في السيرفر. الرجاء المحاولة لاحقاً',
          errorCode: 'SERVER_ERROR',
          statusCode: response.statusCode,
        );
      } else {
        // خطأ غير متوقع
        throw QuoteApiException(
          'حدث خطأ غير متوقع (${response.statusCode})',
          errorCode: 'UNKNOWN_ERROR',
          statusCode: response.statusCode,
        );
      }
    } on QuoteApiException {
      // إعادة رمي الاستثناءات المخصصة
      rethrow;
    } catch (e) {
      // معالجة الأخطاء العامة
      throw QuoteApiException(
        'فشل الاتصال بالسيرفر. تحقق من اتصال الإنترنت',
        errorCode: 'NETWORK_ERROR',
        originalError: e,
      );
    }
  }

  /// التحقق من صحة رقم الجوال
  static bool isValidPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(r'^05\d{8}$').hasMatch(cleanPhone);
  }

  /// تنظيف رقم الجوال (إزالة المسافات والرموز)
  static String cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }
}

/// استثناء مخصص لأخطاء API طلبات الأسعار
class QuoteApiException implements Exception {
  final String message;
  final String errorCode;
  final int? statusCode;
  final dynamic originalError;

  QuoteApiException(
    this.message, {
    required this.errorCode,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    return 'QuoteApiException: $message (Code: $errorCode)';
  }

  /// رسالة خطأ مناسبة للمستخدم
  String get userFriendlyMessage {
    switch (errorCode) {
      case 'TIMEOUT':
        return 'انتهى الوقت المحدد للطلب. تحقق من اتصال الإنترنت';
      case 'RATE_LIMIT':
        return 'تم إرسال طلبات كثيرة. الرجاء الانتظار دقيقة ثم المحاولة مرة أخرى';
      case 'VALIDATION_ERROR':
        return message; // استخدم الرسالة من السيرفر
      case 'SERVER_ERROR':
        return 'خطأ في السيرفر. الرجاء المحاولة لاحقاً';
      case 'NETWORK_ERROR':
        return 'فشل الاتصال. تحقق من اتصال الإنترنت';
      default:
        return 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى';
    }
  }
}
