import 'package:flutter/foundation.dart';

import '../data/auth_api.dart';
import '../data/auth_storage.dart';

class AuthState extends ChangeNotifier {
  final AuthApi _authApi = AuthApi();
  final AuthStorage _authStorage = AuthStorage();

  String? _token;
  bool _isLoading = false;

  bool get isLoggedIn => _token != null;
  String? get token => _token;
  bool get isLoading => _isLoading;

  /// Load saved token on app startup
  Future<void> loadTokenOnStartup() async {
    _token = await _authStorage.getToken();
    notifyListeners();
  }

  /// Login with phone and password
  Future<void> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authApi.login(
        phone: phone,
        password: password,
      );

      _token = token;
      await _authStorage.saveToken(token);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Register new user
  Future<void> register(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authApi.register(
        phone: phone,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Logout and clear token
  Future<void> logout() async {
    _token = null;
    await _authStorage.clearToken();
    notifyListeners();
  }
}
