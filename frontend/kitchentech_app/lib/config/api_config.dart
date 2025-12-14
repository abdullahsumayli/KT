/// API Configuration for KitchenTech Backend
///
/// Backend is running on: http://localhost:8000
/// API Documentation: http://localhost:8000/docs
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const String apiPrefix = '/api';

  // Auth endpoints
  static const String login = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String me = '$apiPrefix/auth/me';

  // Listings endpoints
  static const String listings = '$apiPrefix/listings';
  static const String myListings = '$apiPrefix/listings/my-listings';

  // Plans endpoints
  static const String plans = '$apiPrefix/plans';
  static const String subscribe = '$apiPrefix/plans/subscribe';
  static const String mySubscriptions = '$apiPrefix/plans/subscriptions/my';
  static const String activeSubscription = '$apiPrefix/plans/subscriptions/active';
  static const String confirmPayment = '$apiPrefix/plans/subscriptions'; // + /{id}/confirm-payment

  // Profile endpoints
  static const String profile = '$apiPrefix/profile/me';
  static const String profileListings = '$apiPrefix/profile/my-listings';

  // Favorites endpoints
  static const String favorites = '$apiPrefix/favorites';
  static const String checkFavorite = '$apiPrefix/favorites/check'; // + /{id}

  // Contact endpoints
  static const String contact = '$apiPrefix/contact';

  // Settings endpoints
  static const String settingsPublic = '$apiPrefix/settings/public';

  // Admin endpoints
  static const String adminDashboard = '$apiPrefix/admin/dashboard/stats';
  static const String adminUsers = '$apiPrefix/admin/users';
  static const String adminListings = '$apiPrefix/admin/listings';
  static const String adminPlans = '$apiPrefix/admin/plans';
  static const String adminSubscriptions = '$apiPrefix/admin/subscriptions';

  // AI endpoints (if implemented later)
  static const String generateDescription = '$apiPrefix/ai/generate-description';
  static const String suggestPrice = '$apiPrefix/ai/suggest-price';
  static const String enhanceListing = '$apiPrefix/ai/enhance-listing';
}
