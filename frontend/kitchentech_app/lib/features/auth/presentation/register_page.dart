import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/shared_widgets.dart';
import '../../shared/data/models/advertiser.dart';

/// صفحة التسجيل مع تبويبات للمشتري والمعلن
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers للمشتري
  final _buyerNameController = TextEditingController();
  final _buyerEmailController = TextEditingController();
  final _buyerPhoneController = TextEditingController();
  final _buyerPasswordController = TextEditingController();
  final _buyerConfirmPasswordController = TextEditingController();

  // Controllers للمعلن
  final _advertiserNameController = TextEditingController();
  final _advertiserEmailController = TextEditingController();
  final _advertiserPhoneController = TextEditingController();
  final _advertiserPasswordController = TextEditingController();
  final _advertiserConfirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _commercialRegistrationController = TextEditingController();

  String? _selectedCity;
  AdvertiserType? _selectedAdvertiserType;
  bool _isLoading = false;
  bool _acceptTerms = false;

  final _buyerFormKey = GlobalKey<FormState>();
  final _advertiserFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buyerNameController.dispose();
    _buyerEmailController.dispose();
    _buyerPhoneController.dispose();
    _buyerPasswordController.dispose();
    _buyerConfirmPasswordController.dispose();
    _advertiserNameController.dispose();
    _advertiserEmailController.dispose();
    _advertiserPhoneController.dispose();
    _advertiserPasswordController.dispose();
    _advertiserConfirmPasswordController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _commercialRegistrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // التبويبات
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.person_outline),
                  text: 'مشتري',
                ),
                Tab(
                  icon: Icon(Icons.store_outlined),
                  text: 'معلن',
                ),
              ],
            ),
          ),

          // محتوى التبويبات
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBuyerForm(),
                _buildAdvertiserForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _buyerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // رسالة ترحيبية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'سجل كمشتري لتصفح المطابخ والتواصل مع المعلنين',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // الاسم الكامل
            TextFormField(
              controller: _buyerNameController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم الكامل';
                }
                if (value.length < 3) {
                  return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // البريد الإلكتروني
            TextFormField(
              controller: _buyerEmailController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال البريد الإلكتروني';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'البريد الإلكتروني غير صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // رقم الجوال
            TextFormField(
              controller: _buyerPhoneController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الجوال',
                prefixIcon: const Icon(Icons.phone),
                hintText: '05xxxxxxxx',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الجوال';
                }
                if (!RegExp(r'^05\d{8}$').hasMatch(value)) {
                  return 'رقم الجوال غير صحيح (يجب أن يبدأ بـ 05 ويتكون من 10 أرقام)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // كلمة المرور
            TextFormField(
              controller: _buyerPasswordController,
              textAlign: TextAlign.right,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال كلمة المرور';
                }
                if (value.length < 8) {
                  return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // تأكيد كلمة المرور
            TextFormField(
              controller: _buyerConfirmPasswordController,
              textAlign: TextAlign.right,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء تأكيد كلمة المرور';
                }
                if (value != _buyerPasswordController.text) {
                  return 'كلمة المرور غير متطابقة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // الموافقة على الشروط
            CheckboxListTile(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
              title: const Text(
                'أوافق على الشروط والأحكام وسياسة الخصوصية',
                style: TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 24),

            // زر التسجيل
            PrimaryButton(
              text: 'إنشاء حساب',
              isLoading: _isLoading,
              onPressed: _acceptTerms ? _registerBuyer : null,
            ),
            const SizedBox(height: 16),

            // رابط تسجيل الدخول
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Text('لديك حساب بالفعل؟ '),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvertiserForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _advertiserFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // رسالة ترحيبية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.store, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'سجل كمعلن لعرض وبيع المطابخ',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // نوع المعلن
            DropdownButtonFormField<AdvertiserType>(
              initialValue: _selectedAdvertiserType,
              decoration: InputDecoration(
                labelText: 'نوع النشاط التجاري',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: AdvertiserType.company,
                  child: Text('شركة'),
                ),
                DropdownMenuItem(
                  value: AdvertiserType.workshop,
                  child: Text('ورشة'),
                ),
                DropdownMenuItem(
                  value: AdvertiserType.freelancer,
                  child: Text('فرد'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAdvertiserType = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'الرجاء اختيار نوع النشاط';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // اسم المنشأة
            TextFormField(
              controller: _businessNameController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'اسم المنشأة التجارية',
                prefixIcon: const Icon(Icons.store_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم المنشأة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // الاسم الشخصي
            TextFormField(
              controller: _advertiserNameController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'الاسم الشخصي',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم الشخصي';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // البريد الإلكتروني
            TextFormField(
              controller: _advertiserEmailController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال البريد الإلكتروني';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'البريد الإلكتروني غير صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // رقم الجوال
            TextFormField(
              controller: _advertiserPhoneController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الجوال',
                prefixIcon: const Icon(Icons.phone),
                hintText: '05xxxxxxxx',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الجوال';
                }
                if (!RegExp(r'^05\d{8}$').hasMatch(value)) {
                  return 'رقم الجوال غير صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // المدينة
            DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              decoration: InputDecoration(
                labelText: 'المدينة',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'الرياض', child: Text('الرياض')),
                DropdownMenuItem(value: 'جدة', child: Text('جدة')),
                DropdownMenuItem(value: 'الدمام', child: Text('الدمام')),
                DropdownMenuItem(value: 'مكة', child: Text('مكة')),
                DropdownMenuItem(value: 'المدينة', child: Text('المدينة')),
                DropdownMenuItem(value: 'الخبر', child: Text('الخبر')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'الرجاء اختيار المدينة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // العنوان
            TextFormField(
              controller: _businessAddressController,
              textAlign: TextAlign.right,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'عنوان المنشأة',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال عنوان المنشأة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // السجل التجاري
            TextFormField(
              controller: _commercialRegistrationController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'رقم السجل التجاري (اختياري)',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // كلمة المرور
            TextFormField(
              controller: _advertiserPasswordController,
              textAlign: TextAlign.right,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال كلمة المرور';
                }
                if (value.length < 8) {
                  return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // تأكيد كلمة المرور
            TextFormField(
              controller: _advertiserConfirmPasswordController,
              textAlign: TextAlign.right,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء تأكيد كلمة المرور';
                }
                if (value != _advertiserPasswordController.text) {
                  return 'كلمة المرور غير متطابقة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // الموافقة على الشروط
            CheckboxListTile(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
              title: const Text(
                'أوافق على الشروط والأحكام وسياسة الخصوصية',
                style: TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 24),

            // زر التسجيل
            PrimaryButton(
              text: 'إنشاء حساب معلن',
              isLoading: _isLoading,
              onPressed: _acceptTerms ? _registerAdvertiser : null,
            ),
            const SizedBox(height: 16),

            // رابط تسجيل الدخول
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Text('لديك حساب بالفعل؟ '),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerBuyer() async {
    if (!_buyerFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الحساب بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home
      context.go('/');
    }
  }

  Future<void> _registerAdvertiser() async {
    if (!_advertiserFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الحساب بنجاح! في انتظار مراجعة الإدارة'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home
      context.go('/');
    }
  }
}
