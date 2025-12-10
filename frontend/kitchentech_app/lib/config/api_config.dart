class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const String apiVersion = '/api/v1';

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String me = '$apiVersion/auth/me';

  // Listings endpoints
  static const String listings = '$apiVersion/listings';
  static const String myListings = '$apiVersion/listings/my-listings';

  // AI endpoints
  static const String generateDescription = '$apiVersion/ai/generate-description';
  static const String suggestPrice = '$apiVersion/ai/suggest-price';
  static const String enhanceListing = '$apiVersion/ai/enhance-listing';
}
