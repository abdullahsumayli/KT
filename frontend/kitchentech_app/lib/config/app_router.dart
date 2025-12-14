import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/presentation/admin_panel_page_v2.dart';
import '../features/ai_wizard/presentation/ai_wizard_screen.dart';
import '../features/auth/presentation/login_screen_v2.dart';
import '../features/auth/presentation/register_screen_v2.dart';
import '../features/contact/presentation/contact_page_v2.dart';
import '../features/dashboard/presentation/add_ad_wizard_v2.dart';
import '../features/dashboard/presentation/advertiser_dashboard_v2.dart';
import '../features/favorites/presentation/favorites_page_v2.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/info/presentation/how_it_works_page_v2.dart';
import '../features/listings/presentation/listings_screen_v2.dart';
import '../features/plans/presentation/checkout_page.dart';
import '../features/plans/presentation/plans_page_v2.dart';
import '../features/product/presentation/product_detail_screen_v2.dart';
import '../features/profile/presentation/profile_page_v2.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/kitchens',
      name: 'kitchens',
      builder: (context, state) {
        final args = state.uri.queryParameters;
        return ListingsScreenV2(
          category: args['category'],
          searchQuery: args['search'],
          city: args['city'],
        );
      },
    ),
    GoRoute(
      path: '/kitchens/:id',
      name: 'kitchen-detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailScreenV2(
          id: id,
        );
      },
    ),
    GoRoute(
      path: '/auth/login',
      name: 'login',
      builder: (context, state) => const LoginScreenV2(),
    ),
    GoRoute(
      path: '/auth/register',
      name: 'register',
      builder: (context, state) => const RegisterScreenV2(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const AdvertiserDashboardV2(),
    ),
    GoRoute(
      path: '/dashboard/new-ad',
      name: 'new-ad',
      builder: (context, state) => const AddAdWizardV2(),
    ),
    GoRoute(
      path: '/plans',
      name: 'plans',
      builder: (context, state) => const PlansPageV2(),
    ),
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) => CheckoutPage(
        planDetails: state.extra as Map<String, dynamic>?,
      ),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePageV2(),
    ),
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const FavoritesPageV2(),
    ),
    GoRoute(
      path: '/how-it-works',
      name: 'how-it-works',
      builder: (context, state) => const HowItWorksPageV2(),
    ),
    GoRoute(
      path: '/contact',
      name: 'contact',
      builder: (context, state) => const ContactPageV2(),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminPanelPageV2(),
    ),
    GoRoute(
      path: '/ai-wizard',
      name: 'ai-wizard',
      builder: (context, state) => const AiWizardScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'الصفحة غير موجودة',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(state.uri.toString()),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('العودة للرئيسية'),
          ),
        ],
      ),
    ),
  ),
);
