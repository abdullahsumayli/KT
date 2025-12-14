import 'package:flutter_test/flutter_test.dart';
import 'package:kitchentech_app/services/quote_api_service.dart';

void main() {
  group('QuoteApiService Integration Tests', () {
    test('submitQuoteRequest - should create quote successfully', () async {
      // Arrange
      const testData = {'style': 'modern', 'city': 'riyadh', 'phone': '0512345670'};

      // Act
      final response = await QuoteApiService.submitQuoteRequest(
        style: testData['style']!,
        city: testData['city']!,
        phone: testData['phone']!,
      );

      // Assert
      expect(response, isA<Map<String, dynamic>>());
      expect(response['id'], isNotNull);
      expect(response['style'], equals('modern'));
      expect(response['city'], equals('riyadh'));
      expect(response['phone'], equals('0512345670'));
      expect(response['status'], equals('new'));
      expect(response['created_at'], isNotNull);

      print('✅ Integration Test Passed: Quote ID ${response['id']}');
    });

    test('submitQuoteRequest - should handle invalid phone', () async {
      // Arrange & Act & Assert
      expect(
        () async => await QuoteApiService.submitQuoteRequest(
          style: 'modern',
          city: 'riyadh',
          phone: '123', // Invalid phone
        ),
        throwsA(isA<QuoteApiException>()),
      );
    });

    test('isValidPhone - should validate phone numbers correctly', () {
      // Valid phones
      expect(QuoteApiService.isValidPhone('0512345678'), isTrue);
      expect(QuoteApiService.isValidPhone('0599999999'), isTrue);
      expect(QuoteApiService.isValidPhone('05 1234 5678'), isTrue);
      expect(QuoteApiService.isValidPhone('05-1234-5678'), isTrue);

      // Invalid phones
      expect(QuoteApiService.isValidPhone('1234567890'), isFalse);
      expect(QuoteApiService.isValidPhone('05123456'), isFalse);
      expect(QuoteApiService.isValidPhone('06123456789'), isFalse);
      expect(QuoteApiService.isValidPhone(''), isFalse);
    });

    test('cleanPhone - should remove formatting', () {
      expect(QuoteApiService.cleanPhone('05 1234 5678'), equals('0512345678'));
      expect(QuoteApiService.cleanPhone('05-1234-5678'), equals('0512345678'));
      expect(QuoteApiService.cleanPhone('(05) 1234-5678'), equals('0512345678'));
    });
  });

  group('QuoteApiException Tests', () {
    test('should provide user-friendly messages', () {
      final timeoutException = QuoteApiException('Timeout', errorCode: 'TIMEOUT');
      expect(timeoutException.userFriendlyMessage, contains('انتهى الوقت'));

      final rateLimitException = QuoteApiException('Rate limit', errorCode: 'RATE_LIMIT');
      expect(rateLimitException.userFriendlyMessage, contains('تم إرسال طلبات كثيرة'));

      final networkException = QuoteApiException('Network error', errorCode: 'NETWORK_ERROR');
      expect(networkException.userFriendlyMessage, contains('فشل الاتصال'));
    });
  });
}
