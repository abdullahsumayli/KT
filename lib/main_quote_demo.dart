import 'package:flutter/material.dart';
import 'widgets/quote_request_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سوق مطبخ - QuoteRequestForm Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Cairo', // إذا كان الخط مضافاً للمشروع
      ),
      home: const QuoteRequestFormDemo(),
    );
  }
}

class QuoteRequestFormDemo extends StatelessWidget {
  const QuoteRequestFormDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'نموذج طلب عرض السعر',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // المكون الرئيسي
            const QuoteRequestForm(),
            
            const SizedBox(height: 40),
            
            // معلومات إضافية
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'لماذا نموذج طلب العرض؟',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    '✅',
                    'تحويل الزوار إلى عملاء محتملين بشكل فعال',
                  ),
                  _buildInfoItem(
                    '📊',
                    'جمع بيانات العملاء لتحليل الطلب والسوق',
                  ),
                  _buildInfoItem(
                    '🎯',
                    'توفير تجربة مستخدم سلسة وجذابة',
                  ),
                  _buildInfoItem(
                    '⚡',
                    'استجابة سريعة مع حالة تحميل واضحة',
                  ),
                  _buildInfoItem(
                    '🛡️',
                    'تحقق من صحة البيانات قبل الإرسال',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
