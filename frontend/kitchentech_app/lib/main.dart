import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/kitchen_tech_app.dart';
import 'features/auth/state/auth_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthState()..loadTokenOnStartup(),
      child: const KitchenTechApp(),
    ),
  );
}
