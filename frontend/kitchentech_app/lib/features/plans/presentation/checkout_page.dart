import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Spec 2.7: صفحة الدفع (Checkout Page)
/// صفحة دفع بسيطة وآمنة لإتمام الاشتراك
class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic>? planDetails;

  const CheckoutPage({super.key, this.planDetails});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  // Payment method
  String _selectedPaymentMethod = 'card'; // 'card' or 'stcpay'

  // Card details
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  // STC Pay
  final _stcPayPhoneController = TextEditingController();

  // Billing info
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _saveCardInfo = false;
  bool _agreeToTerms = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _stcPayPhoneController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 1000;

    final planTitle = widget.planDetails?['planTitle'] ?? 'الباقة الأساسية';
    final planPrice = widget.planDetails?['planPrice'] ?? '299';
    final planPeriod = widget.planDetails?['planPeriod'] ?? 'شهرياً';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('إتمام الدفع'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: EdgeInsets.all(isWide ? 40 : 16),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Payment Form
                        Expanded(
                          flex: 2,
                          child: _buildPaymentForm(context, theme),
                        ),
                        const SizedBox(width: 32),
                        // Order Summary
                        Expanded(
                          flex: 1,
                          child: _buildOrderSummary(
                            context,
                            theme,
                            planTitle,
                            planPrice,
                            planPeriod,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        // Order Summary
                        _buildOrderSummary(
                          context,
                          theme,
                          planTitle,
                          planPrice,
                          planPeriod,
                        ),
                        const SizedBox(height: 24),
                        // Payment Form
                        _buildPaymentForm(context, theme),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الدفع',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method Selection
            _buildPaymentMethodSelector(theme),
            const SizedBox(height: 32),

            // Payment Method Forms
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedPaymentMethod == 'card'
                  ? _buildCardPaymentForm(theme)
                  : _buildSTCPayForm(theme),
            ),
            const SizedBox(height: 32),

            // Billing Information
            Text(
              'معلومات الفاتورة',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBillingForm(theme),
            const SizedBox(height: 24),

            // Terms Agreement
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreeToTerms = !_agreeToTerms;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                        ),
                        children: [
                          const TextSpan(text: 'أوافق على '),
                          TextSpan(
                            text: 'الشروط والأحكام',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ' و'),
                          TextSpan(
                            text: 'سياسة الخصوصية',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agreeToTerms && !_isProcessing ? _processPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'إتمام الدفع بشكل آمن',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Security Note
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'معلوماتك محمية بتشفير SSL 256-bit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة الدفع',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodCard(
                icon: Icons.credit_card,
                title: 'بطاقة بنكية',
                subtitle: 'مدى، فيزا، ماستركارد',
                value: 'card',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPaymentMethodCard(
                icon: Icons.phone_android,
                title: 'STC Pay',
                subtitle: 'محفظة رقمية',
                value: 'stcpay',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.blue : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPaymentForm(ThemeData theme) {
    return Column(
      key: const ValueKey('card'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Number
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'رقم البطاقة',
            hintText: '1234 5678 9012 3456',
            prefixIcon: const Icon(Icons.credit_card),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            _CardNumberFormatter(),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال رقم البطاقة';
            }
            if (value.replaceAll(' ', '').length < 16) {
              return 'رقم البطاقة غير صحيح';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Card Holder Name
        TextFormField(
          controller: _cardHolderController,
          decoration: InputDecoration(
            labelText: 'اسم حامل البطاقة',
            hintText: 'كما هو مكتوب على البطاقة',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال اسم حامل البطاقة';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Expiry & CVV
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: 'تاريخ الانتهاء',
                  hintText: 'MM/YY',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryDateFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'مطلوب';
                  }
                  if (!value.contains('/') || value.length != 5) {
                    return 'غير صحيح';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'مطلوب';
                  }
                  if (value.length != 3) {
                    return 'غير صحيح';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Save Card Checkbox
        Row(
          children: [
            Checkbox(
              value: _saveCardInfo,
              onChanged: (value) {
                setState(() {
                  _saveCardInfo = value ?? false;
                });
              },
            ),
            const Expanded(
              child: Text('حفظ معلومات البطاقة للمرة القادمة'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSTCPayForm(ThemeData theme) {
    return Column(
      key: const ValueKey('stcpay'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple[100]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.purple[700]),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'سيتم إرسال طلب دفع إلى تطبيق STC Pay الخاص بك',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Phone Number
        TextFormField(
          controller: _stcPayPhoneController,
          decoration: InputDecoration(
            labelText: 'رقم الجوال المرتبط بـ STC Pay',
            hintText: '05xxxxxxxx',
            prefixIcon: const Icon(Icons.phone_android),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال رقم الجوال';
            }
            if (!value.startsWith('05') || value.length != 10) {
              return 'رقم الجوال غير صحيح';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBillingForm(ThemeData theme) {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'البريد الإلكتروني',
            hintText: 'example@email.com',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال البريد الإلكتروني';
            }
            if (!value.contains('@')) {
              return 'البريد الإلكتروني غير صحيح';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'رقم الجوال',
            hintText: '05xxxxxxxx',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال رقم الجوال';
            }
            if (!value.startsWith('05') || value.length != 10) {
              return 'رقم الجوال غير صحيح';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    ThemeData theme,
    String planTitle,
    String planPrice,
    String planPeriod,
  ) {
    final vat = (double.parse(planPrice) * 0.15).toStringAsFixed(2);
    final total = (double.parse(planPrice) * 1.15).toStringAsFixed(2);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الطلب',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Plan Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  planPeriod,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Price Breakdown
          _buildPriceRow('سعر الباقة', '$planPrice ريال', theme),
          const SizedBox(height: 12),
          _buildPriceRow('ضريبة القيمة المضافة (15%)', '$vat ريال', theme),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildPriceRow(
            'الإجمالي',
            '$total ريال',
            theme,
            isTotal: true,
          ),
          const SizedBox(height: 24),

          // Features Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'ما سوف تحصل عليه:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFeatureItem('بدء الاشتراك فوراً'),
                _buildFeatureItem('إمكانية الإلغاء في أي وقت'),
                _buildFeatureItem('دعم فني متواصل'),
                _buildFeatureItem('تحديثات مجانية'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value,
    ThemeData theme, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : null,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 20 : null,
            color: isTotal ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'تم الدفع بنجاح!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'تم تفعيل اشتراكك وسيتم إرسال تفاصيل الفاتورة إلى بريدك الإلكتروني',
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.go('/dashboard');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'الذهاب إلى لوحة التحكم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Card Number Formatter
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

// Expiry Date Formatter
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.length >= 2 && !text.contains('/')) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}/${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }

    return newValue;
  }
}
