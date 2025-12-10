import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthApi {
  final String baseUrl = 'http://localhost:8000/api/v1';

  /// Register a new user with phone and password
  Future<void> register({
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to register');
    }
  }

  /// Login with phone and password, returns JWT access token
  Future<String> login({
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login/phone');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to login');
    }

    final data = jsonDecode(response.body);
    return data['access_token'] as String;
  }
}
