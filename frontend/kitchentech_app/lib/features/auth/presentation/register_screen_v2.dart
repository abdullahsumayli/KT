import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// شاشة إنشاء الحساب - Spec 2.4
class RegisterScreenV2 extends StatefulWidget {
  const RegisterScreenV2({super.key});

  @override
  State<RegisterScreenV2> createState() => _RegisterScreenV2State();
}

class _RegisterScreenV2State extends State<RegisterScreenV2> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _clientFormKey = GlobalKey<FormState>();
  final _advertiserFormKey = GlobalKey<FormState>();

  // حقول العميل
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientPasswordController = TextEditingController();
  final _clientConfirmPasswordController = TextEditingController();
  String? _clientCity;

  // حقول المعلن
  final _companyNameController = TextEditingController();
  final _advertiserEmailController = TextEditingController();
  final _advertiserPhoneController = TextEditingController();
  final _advertiserPasswordController = TextEditingController();
  final _advertiserConfirmPasswordController = TextEditingController();
  final _commercialRegController = TextEditingController();
  final _websiteController = TextEditingController();
  String? _advertiserCity;
  String? _advertiserType;

  bool _clientObscurePassword = true;
  bool _clientObscureConfirm = true;
  bool _advertiserObscurePassword = true;
  bool _advertiserObscureConfirm = true;
  bool _clientAcceptTerms = false;
  bool _advertiserAcceptTerms = false;
  bool _isLoading = false;

  final List<String> _cities = [
    'الرياض',
    'جدة',
    'مكة المكرمة',
    'المدينة المنورة',
    'الدمام',
    'الخبر',
    'الظهران',
    'الطائف',
    'أبها',
    'تبوك',
    'بريدة',
    'خميس مشيط',
    'حائل',
    'نجران',
    'الجبيل',
    'ينبع',
  ];

  final List<String> _advertiserTypes = [
    'شركة',
    'ورشة',
    'مصمم مستقل',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    _clientPasswordController.dispose();
    _clientConfirmPasswordController.dispose();
    _companyNameController.dispose();
    _advertiserEmailController.dispose();
    _advertiserPhoneController.dispose();
    _advertiserPasswordController.dispose();
    _advertiserConfirmPasswordController.dispose();
    _commercialRegController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _handleClientRegister() async {
    if (!_clientFormKey.currentState!.validate()) {
      return;
    }

    if (!_clientAcceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على الشروط والأحكام'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إنشاء حسابك بنجاح! أهلاً بك'),
        backgroundColor: Colors.green,
      ),
    );

    context.go('/');
  }

  Future<void> _handleAdvertiserRegister() async {
    if (!_advertiserFormKey.currentState!.validate()) {
      return;
    }

    if (!_advertiserAcceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على الشروط والأحكام'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إنشاء حسابك كمعلن بنجاح! سيتم مراجعة بياناتك'),
        backgroundColor: Colors.green,
      ),
    );

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text(
            'إنشاء حساب جديد',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/auth/login'),
          ),
        ),
        body: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isWide ? 800 : size.width,
            ),
            child: Column(
              children: [
                // التبويبات
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.person),
                        text: 'مستخدم (عميل)',
                      ),
                      Tab(
                        icon: Icon(Icons.business),
                        text: 'معلن',
                      ),
                    ],
                  ),
                ),
                // المحتوى
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildClientForm(),
                      _buildAdvertiserForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _clientFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'إنشاء حساب عميل',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سجّل بياناتك لتتمكن من تصفح وحفظ المطابخ المفضلة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            // الاسم الكامل
            TextFormField(
              controller: _clientNameController,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل *',
                hintText: 'أدخل اسمك الكامل',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
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
              controller: _clientEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني *',
                hintText: 'example@email.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال البريد الإلكتروني';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'الرجاء إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // رقم الجوال
            TextFormField(
              controller: _clientPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الجوال *',
                hintText: '05xxxxxxxx',
                prefixIcon: const Icon(Icons.phone_outlined),
                prefixText: '+966 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الجوال';
                }
                if (value.length < 9) {
                  return 'رقم الجوال غير صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // مدينة السكن
            DropdownButtonFormField<String>(
              initialValue: _clientCity,
              decoration: InputDecoration(
                labelText: 'مدينة السكن *',
                prefixIcon: const Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _cities
                  .map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _clientCity = value;
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

            // كلمة المرور
            TextFormField(
              controller: _clientPasswordController,
              obscureText: _clientObscurePassword,
              decoration: InputDecoration(
                labelText: 'كلمة المرور *',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _clientObscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _clientObscurePassword = !_clientObscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
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
              controller: _clientConfirmPasswordController,
              obscureText: _clientObscureConfirm,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور *',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _clientObscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _clientObscureConfirm = !_clientObscureConfirm;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء تأكيد كلمة المرور';
                }
                if (value != _clientPasswordController.text) {
                  return 'كلمة المرور غير متطابقة';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // الموافقة على الشروط
            Row(
              children: [
                Checkbox(
                  value: _clientAcceptTerms,
                  onChanged: (value) {
                    setState(() {
                      _clientAcceptTerms = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _clientAcceptTerms = !_clientAcceptTerms;
                      });
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'أوافق على ',
                        style: TextStyle(color: Colors.grey.shade700),
                        children: [
                          TextSpan(
                            text: 'الشروط والأحكام',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ' و'),
                          TextSpan(
                            text: 'سياسة الخصوصية',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
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
            const SizedBox(height: 24),

            // زر التسجيل
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleClientRegister,
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
                        'إنشاء الحساب',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // لديك حساب؟
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'لديك حساب بالفعل؟',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvertiserForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _advertiserFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'إنشاء حساب معلن',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سجّل بيانات شركتك/ورشتك لتبدأ في عرض مطابخك على المنصة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            // اسم الشركة / الاسم التجاري
            TextFormField(
              controller: _companyNameController,
              decoration: InputDecoration(
                labelText: 'اسم الشركة / الاسم التجاري *',
                hintText: 'مثال: مؤسسة المطابخ الفاخرة',
                prefixIcon: const Icon(Icons.business_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم الشركة';
                }
                if (value.length < 3) {
                  return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // نوع المعلن
            DropdownButtonFormField<String>(
              initialValue: _advertiserType,
              decoration: InputDecoration(
                labelText: 'نوع المعلن *',
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _advertiserTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _advertiserType = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'الرجاء اختيار نوع المعلن';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // المدينة
            DropdownButtonFormField<String>(
              initialValue: _advertiserCity,
              decoration: InputDecoration(
                labelText: 'المدينة *',
                prefixIcon: const Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _cities
                  .map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _advertiserCity = value;
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

            // رقم السجل التجاري
            TextFormField(
              controller: _commercialRegController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'رقم السجل التجاري (موصى به)',
                hintText: '1234567890',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                helperText: 'السجل التجاري يزيد من مصداقيتك',
              ),
            ),
            const SizedBox(height: 16),

            // البريد الإلكتروني الرسمي
            TextFormField(
              controller: _advertiserEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني الرسمي *',
                hintText: 'info@company.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال البريد الإلكتروني';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'الرجاء إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // جوال التواصل
            TextFormField(
              controller: _advertiserPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'جوال التواصل *',
                hintText: '05xxxxxxxx',
                prefixIcon: const Icon(Icons.phone_outlined),
                prefixText: '+966 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الجوال';
                }
                if (value.length < 9) {
                  return 'رقم الجوال غير صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // موقع إلكتروني / إنستغرام
            TextFormField(
              controller: _websiteController,
              decoration: InputDecoration(
                labelText: 'موقع إلكتروني / إنستغرام (اختياري)',
                hintText: 'www.example.com أو @username',
                prefixIcon: const Icon(Icons.language_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // كلمة المرور
            TextFormField(
              controller: _advertiserPasswordController,
              obscureText: _advertiserObscurePassword,
              decoration: InputDecoration(
                labelText: 'كلمة المرور *',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _advertiserObscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _advertiserObscurePassword = !_advertiserObscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
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
              obscureText: _advertiserObscureConfirm,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور *',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _advertiserObscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _advertiserObscureConfirm = !_advertiserObscureConfirm;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
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
            const SizedBox(height: 24),

            // ملاحظة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'سيتم مراجعة بياناتك خلال 24-48 ساعة قبل تفعيل حسابك',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // الموافقة على الشروط
            Row(
              children: [
                Checkbox(
                  value: _advertiserAcceptTerms,
                  onChanged: (value) {
                    setState(() {
                      _advertiserAcceptTerms = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _advertiserAcceptTerms = !_advertiserAcceptTerms;
                      });
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'أوافق على ',
                        style: TextStyle(color: Colors.grey.shade700),
                        children: [
                          TextSpan(
                            text: 'الشروط والأحكام',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ' و'),
                          TextSpan(
                            text: 'سياسة الخصوصية',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
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
            const SizedBox(height: 24),

            // زر التسجيل
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleAdvertiserRegister,
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
                        'إنشاء حساب المعلن',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // لديك حساب؟
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'لديك حساب بالفعل؟',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
