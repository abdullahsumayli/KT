import 'package:flutter/material.dart';

import '../widgets/quote_request_form.dart';

/// تطبيق تجريبي لاختبار نموذج طلب عروض الأسعار
/// يستخدم لاختبار الاتصال بـ API الإنتاج
void main() {
  runApp(const QuoteFormTestApp());
}

class QuoteFormTestApp extends StatelessWidget {
  const QuoteFormTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اختبار نموذج الطلبات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial', // استخدم خط عربي إن وجد
        useMaterial3: true,
      ),
      home: const QuoteFormTestPage(),
    );
  }
}

class QuoteFormTestPage extends StatelessWidget {
  const QuoteFormTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار نموذج طلبات المطابخ'),
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
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // معلومات الاختبار
                    Card(
                      color: Colors.amber[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.info_outline, size: 40, color: Colors.orange),
                            const SizedBox(height: 12),
                            const Text(
                              'وضع الاختبار',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'متصل بـ API الإنتاج:\nhttps://souqmatbakh.com/api/v1/quotes/',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontFamily: 'Courier',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '✅ جاهز للاختبار',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // النموذج الفعلي
                    const QuoteRequestForm(),

                    const SizedBox(height: 20),

                    // ملاحظات
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📝 ملاحظات الاختبار',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildNote('استخدم رقم جوال حقيقي بصيغة: 05XXXXXXXX'),
                            _buildNote('لا يمكن إرسال طلبين من نفس الرقم خلال 24 ساعة'),
                            _buildNote('يمكن التحقق من الطلبات في لوحة الإدارة'),
                            _buildNote('Rate limit: 10 طلبات في الدقيقة لكل IP'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNote(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }
}
