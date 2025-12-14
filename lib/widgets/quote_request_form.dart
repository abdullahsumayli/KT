import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// مكون نموذج طلب عرض سعر المطبخ
/// يدعم RTL واللغة العربية بشكل كامل
class QuoteRequestForm extends StatefulWidget {
  const QuoteRequestForm({super.key});

  @override
  State<QuoteRequestForm> createState() => _QuoteRequestFormState();
}

class _QuoteRequestFormState extends State<QuoteRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  // حالة النموذج
  bool _isLoading = false;
  String? _selectedStyle;
  String? _selectedCity;

  // خيارات أنواع المطابخ
  final List<Map<String, dynamic>> _kitchenStyles = [
    {'id': 'modern', 'label': 'مودرن', 'icon': Icons.architecture},
    {'id': 'classic', 'label': 'كلاسيك', 'icon': Icons.chair},
    {'id': 'wood', 'label': 'خشب طبيعي', 'icon': Icons.forest},
    {'id': 'aluminum', 'label': 'ألمنيوم / صاج', 'icon': Icons.construction},
  ];

  // خيارات المدن
  final List<Map<String, String>> _cities = [
    {'id': 'riyadh', 'label': 'الرياض'},
    {'id': 'jeddah', 'label': 'جدة'},
    {'id': 'dammam', 'label': 'الدمام / الخبر'},
    {'id': 'other', 'label': 'أخرى'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// دالة التحقق من صحة رقم الجوال
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الجوال';
    }

    // إزالة المسافات والرموز
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // التحقق من أن الرقم يتكون من 10 أرقام ويبدأ بـ 05
    if (!RegExp(r'^05\d{8}$').hasMatch(cleanPhone)) {
      return 'الرجاء إدخال رقم جوال صحيح (05xxxxxxxx)';
    }

    return null;
  }

  /// دالة إرسال النموذج
  Future<void> _submitForm() async {
    // التحقق من صحة الحقول
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // التحقق من اختيار نوع المطبخ
    if (_selectedStyle == null) {
      _showSnackBar('الرجاء اختيار نوع المطبخ', isError: true);
      return;
    }

    // تفعيل حالة التحميل
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: استبدل برابط API الحقيقي
      // const apiUrl = 'https://souqmatbakh.com/api/v1/quotes';
      
      // محاكاة إرسال البيانات إلى API
      await Future.delayed(const Duration(seconds: 1));

      // هيكل البيانات المرسلة
      final requestData = {
        'style': _selectedStyle,
        'city': _selectedCity,
        'phone': _phoneController.text.trim(),
      };

      // طباعة البيانات للتطوير (يمكن حذفها في الإنتاج)
      debugPrint('📤 طلب عرض السعر: $requestData');

      /* 
      // مثال على استدعاء API الحقيقي:
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode != 201) {
        throw Exception('فشل الإرسال');
      }
      */

      // إظهار رسالة نجاح
      if (mounted) {
        _showSnackBar(
          '✅ تم إرسال طلبك بنجاح! سنتواصل معك خلال 24 ساعة',
          isError: false,
        );

        // إعادة تعيين النموذج
        _resetForm();
      }
    } catch (e) {
      // في حالة حدوث خطأ
      if (mounted) {
        _showSnackBar('❌ حدث خطأ أثناء الإرسال. الرجاء المحاولة مرة أخرى', isError: true);
      }
    } finally {
      // إيقاف حالة التحميل
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// إعادة تعيين النموذج
  void _resetForm() {
    setState(() {
      _selectedStyle = null;
      _selectedCity = null;
      _phoneController.clear();
    });
    _formKey.currentState?.reset();
  }

  /// إظهار رسالة Snackbar
  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الرأس (Header)
            _buildHeader(),

            // محتوى النموذج
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان قسم نوع المطبخ
                    _buildSectionTitle('اختر نوع المطبخ المطلوب'),
                    const SizedBox(height: 12),

                    // خيارات نوع المطبخ
                    _buildKitchenStyleSelector(),
                    const SizedBox(height: 24),

                    // حقل المدينة
                    _buildSectionTitle('المدينة'),
                    const SizedBox(height: 12),
                    _buildCityDropdown(),
                    const SizedBox(height: 24),

                    // حقل رقم الجوال
                    _buildSectionTitle('رقم الجوال'),
                    const SizedBox(height: 12),
                    _buildPhoneField(),
                    const SizedBox(height: 32),

                    // زر الإرسال
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء رأس النموذج
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[900]!],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // العنوان الرئيسي
          Text(
            'فصّل مطبخ أحلامك! 🏠',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // النص الفرعي
          Text(
            'أكمل النموذج واحصل على 3 عروض أسعار تنافسية من أفضل المصانع',
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.95), height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// بناء عنوان القسم
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
    );
  }

  /// بناء محدد نوع المطبخ
  Widget _buildKitchenStyleSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _kitchenStyles.map((style) {
        final isSelected = _selectedStyle == style['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedStyle = style['id'];
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[100] : Colors.grey[100],
              border: Border.all(
                color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                width: isSelected ? 2.5 : 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  style['icon'] as IconData,
                  color: isSelected ? Colors.blue[700] : Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  style['label'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.blue[900] : Colors.grey[800],
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle, color: Colors.blue[700], size: 20),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// بناء قائمة المدن المنسدلة
  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCity,
      decoration: InputDecoration(
        hintText: 'اختر المدينة',
        prefixIcon: const Icon(Icons.location_city, color: Colors.blue),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
      icon: Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
      dropdownColor: Colors.white,
      isExpanded: true,
      items: _cities.map((city) {
        return DropdownMenuItem<String>(
          value: city['id'],
          child: Text(city['label']!, style: const TextStyle(fontSize: 16)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCity = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء اختيار المدينة';
        }
        return null;
      },
    );
  }

  /// بناء حقل رقم الجوال
  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        hintText: '05xxxxxxxx',
        hintTextDirection: TextDirection.ltr,
        prefixIcon: const Icon(Icons.phone_android, color: Colors.blue),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      style: const TextStyle(fontSize: 18, letterSpacing: 1.5),
      validator: _validatePhone,
    );
  }

  /// بناء زر الإرسال
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber[600],
          foregroundColor: Colors.grey[900],
          disabledBackgroundColor: Colors.grey[300],
          elevation: _isLoading ? 0 : 4,
          shadowColor: Colors.amber[700]?.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🚀', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Text(
                    'أرسل طلبي للمصانع الآن',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
