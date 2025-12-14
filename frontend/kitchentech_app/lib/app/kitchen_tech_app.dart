import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../config/app_router.dart';
import '../theme/app_theme.dart';

class KitchenTechApp extends StatelessWidget {
  const KitchenTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
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

      // Builder to wrap all pages with RTL
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
