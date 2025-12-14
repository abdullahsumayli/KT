import 'package:flutter/material.dart';

import 'admin/admin_login_page.dart';

void main() {
  runApp(const AdminDashboardDemo());
}

/// تطبيق تجريبي للـ Admin Dashboard
class AdminDashboardDemo extends StatelessWidget {
  const AdminDashboardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سوق مطبخ - لوحة الإدارة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true, fontFamily: 'Arial'),
      home: const AdminLoginPage(),
    );
  }
}
