import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// شاشة تسجيل الدخول - Spec 2.4
class LoginScreenV2 extends StatefulWidget {
  const LoginScreenV2({super.key});

  @override
  State<LoginScreenV2> createState() => _LoginScreenV2State();
}

class _LoginScreenV2State extends State<LoginScreenV2> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل الدخول بنجاح'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to home
    context.go('/');
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نسيت كلمة المرور؟'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('أدخل بريدك الإلكتروني أو رقم جوالك'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني / الجوال',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال رابط إعادة تعيين كلمة المرور'),
                ),
              );
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isWide ? 1200 : size.width,
              ),
              child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // الجانب الأيسر - معلومات وصورة
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(60),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.kitchen,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'مرحباً بك في\nمنصة تقنية المطابخ',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'أفضل منصة لتصفح وشراء المطابخ في السعودية',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 40),
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    _buildFeature('آلاف المطابخ', Icons.kitchen_outlined),
                    _buildFeature('معلنون موثوقون', Icons.verified),
                    _buildFeature('أسعار منافسة', Icons.price_check),
                    _buildFeature('تواصل مباشر', Icons.chat),
                  ],
                ),
              ],
            ),
          ),
        ),
        // الجانب الأيمن - نموذج تسجيل الدخول
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(60),
            color: Colors.white,
            child: _buildLoginForm(),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildLoginForm(),
    );
  }

  Widget _buildFeature(String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شعار
          Center(
            child: Icon(
              Icons.kitchen,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'تسجيل الدخول',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'أهلاً بعودتك! سجّل دخولك للمتابعة',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // البريد الإلكتروني / الجوال
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني أو رقم الجوال',
              hintText: 'example@email.com أو 05xxxxxxxx',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال البريد الإلكتروني أو رقم الجوال';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // كلمة المرور
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال كلمة المرور';
              }
              if (value.length < 6) {
                return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // نسيت كلمة المرور
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _handleForgotPassword,
              child: const Text('نسيت كلمة المرور؟'),
            ),
          ),
          const SizedBox(height: 24),

          // زر تسجيل الدخول
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // أو
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'أو',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 24),

          // تسجيل عبر Google
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('سيتم إضافة التسجيل عبر Google قريباً'),
                ),
              );
            },
            icon: Image.network(
              'https://www.google.com/favicon.ico',
              width: 20,
              height: 20,
            ),
            label: const Text('تسجيل الدخول عبر Google'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // تسجيل عبر Apple
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('سيتم إضافة التسجيل عبر Apple قريباً'),
                ),
              );
            },
            icon: const Icon(Icons.apple, size: 24),
            label: const Text('تسجيل الدخول عبر Apple'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // التسجيل كمستخدم جديد
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ليس لديك حساب؟',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              TextButton(
                onPressed: () => context.go('/auth/register'),
                child: const Text(
                  'تسجيل كمستخدم جديد',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // العودة للرئيسية
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('العودة للصفحة الرئيسية'),
          ),
        ],
      ),
    );
  }
}
