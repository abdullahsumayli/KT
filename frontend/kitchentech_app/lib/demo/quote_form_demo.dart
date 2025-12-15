import 'package:flutter/material.dart';

import '../widgets/quote_request_form.dart';

/// تطبيق تجريبي بسيط لاختبار مكون QuoteRequestForm داخل مشروع kitchentech_app
void main() {
  runApp(const QuoteFormDemoApp());
}

class QuoteFormDemoApp extends StatelessWidget {
  const QuoteFormDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اختبار نموذج الطلبات - سوق المطابخ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const QuoteFormDemoPage(),
    );
  }
}

class QuoteFormDemoPage extends StatelessWidget {
  const QuoteFormDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار نموذج طلب المطابخ'),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: const QuoteRequestForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
