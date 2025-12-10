import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/add_listing/presentation/add_listing_screen.dart';
import '../features/ai_wizard/presentation/ai_wizard_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/listings/presentation/listings_screen.dart';
import '../features/product/presentation/product_detail_screen.dart';
import '../theme/app_theme.dart';

class KitchenTechApp extends StatelessWidget {
  const KitchenTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KitchenTech',
      debugShowCheckedModeBanner: false,

      // RTL Configuration
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Theme
      theme: AppTheme.lightTheme,

      // Home wrapped in RTL
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),

      // Routes
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const Directionality(
                textDirection: TextDirection.rtl,
                child: HomeScreen(),
              ),
            );

          case '/listings':
            return MaterialPageRoute(
              builder: (_) => const Directionality(
                textDirection: TextDirection.rtl,
                child: ListingsScreen(),
              ),
              settings: settings,
            );

          case '/product':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => Directionality(
                textDirection: TextDirection.rtl,
                child: ProductDetailScreen(
                  id: args?['id'] ?? '',
                  title: args?['title'] ?? '',
                  city: args?['city'] ?? '',
                  price: args?['price'] ?? 0.0,
                  type: args?['type'] ?? '',
                  aiScore: args?['aiScore'] ?? 0.0,
                  imageUrl: args?['imageUrl'],
                ),
              ),
            );

          case '/add-listing':
            return MaterialPageRoute(
              builder: (_) => const Directionality(
                textDirection: TextDirection.rtl,
                child: AddListingScreen(),
              ),
            );

          case '/ai-wizard':
            return MaterialPageRoute(
              builder: (_) => const Directionality(
                textDirection: TextDirection.rtl,
                child: AiWizardScreen(),
              ),
            );

          default:
            return null;
        }
      },
    );
  }
}
