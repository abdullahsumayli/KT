import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// معالج إضافة إعلان مطبخ - Spec 2.6
class AddAdWizardV2 extends StatefulWidget {
  const AddAdWizardV2({super.key});

  @override
  State<AddAdWizardV2> createState() => _AddAdWizardV2State();
}

class _AddAdWizardV2State extends State<AddAdWizardV2> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: المعلومات الأساسية
  final _titleController = TextEditingController();
  String? _selectedCity;
  String? _selectedKitchenType;
  String? _selectedTargetClient;

  // Step 2: المواصفات الفنية
  final _areaController = TextEditingController();
  final _materialsController = TextEditingController();
  final _completionDaysController = TextEditingController();
  final _warrantyController = TextEditingController();

  // Step 3: التسعير
  final _priceFromController = TextEditingController();
  final _priceToController = TextEditingController();
  final _priceNotesController = TextEditingController();

  // Step 4: الوسائط
  final List<String> _uploadedImages = [];
  String? _videoUrl;

  // Step 5: التفاصيل النصية
  final _descriptionController = TextEditingController();
  final List<String> _selectedServices = [];

  // Step 6: النشر
  String _selectedPlan = 'free';

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

  final List<String> _kitchenTypes = [
    'مودرن',
    'كلاسيك',
    'نيو كلاسيك',
    'مفتوح',
    'منفصل',
    'اقتصادي',
    'فاخر',
    'للشقق',
    'للفلل',
  ];

  final List<String> _targetClients = [
    'شقق',
    'فلل',
    'شقق تمليك',
    'عمائر سكنية',
    'مكاتب تجارية',
  ];

  final List<String> _availableServices = [
    'تصميم ثلاثي الأبعاد',
    'إزالة المطبخ القديم',
    'تركيب الأجهزة الكهربائية',
    'توصيل وتركيب مجاني',
    'استشارة مجانية',
    'ضمان ما بعد البيع',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _areaController.dispose();
    _materialsController.dispose();
    _completionDaysController.dispose();
    _warrantyController.dispose();
    _priceFromController.dispose();
    _priceToController.dispose();
    _priceNotesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 5) {
        setState(() {
          _currentStep++;
        });
      } else {
        _submitAd();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_titleController.text.isEmpty ||
            _selectedCity == null ||
            _selectedKitchenType == null ||
            _selectedTargetClient == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الرجاء إكمال جميع الحقول المطلوبة'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;
      case 1:
        if (_areaController.text.isEmpty || _materialsController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الرجاء إكمال المواصفات الفنية'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;
      case 2:
        if (_priceFromController.text.isEmpty || _priceToController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الرجاء إدخال نطاق السعر'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;
      case 3:
        if (_uploadedImages.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الرجاء إضافة صورة رئيسية على الأقل'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;
      case 4:
        if (_descriptionController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الرجاء إضافة وصف للإعلان'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _submitAd() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pop(context); // Close loading

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
          size: 64,
        ),
        title: const Text('تم إرسال الإعلان بنجاح!'),
        content: const Text(
          'سيتم مراجعة إعلانك خلال 24-48 ساعة وستصلك رسالة بالبريد الإلكتروني عند النشر.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
            child: const Text('العودة للوحة التحكم'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetWizard();
            },
            child: const Text('إضافة إعلان آخر'),
          ),
        ],
      ),
    );
  }

  void _resetWizard() {
    setState(() {
      _currentStep = 0;
      _titleController.clear();
      _selectedCity = null;
      _selectedKitchenType = null;
      _selectedTargetClient = null;
      _areaController.clear();
      _materialsController.clear();
      _completionDaysController.clear();
      _warrantyController.clear();
      _priceFromController.clear();
      _priceToController.clear();
      _priceNotesController.clear();
      _uploadedImages.clear();
      _videoUrl = null;
      _descriptionController.clear();
      _selectedServices.clear();
      _selectedPlan = 'free';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text(
            'إضافة إعلان مطبخ جديد',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('إلغاء الإضافة؟'),
                  content: const Text(
                      'هل أنت متأكد من إلغاء إضافة الإعلان؟ سيتم فقد جميع البيانات المدخلة.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('متابعة الإضافة'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/dashboard');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('نعم، إلغاء'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        body: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: _buildStepContent(),
                  ),
                ),
              ),
            ),
            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: List.generate(6, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < 5) const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            _getStepTitle(_currentStep),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'الخطوة ${_currentStep + 1} من 6',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'المعلومات الأساسية';
      case 1:
        return 'المواصفات الفنية';
      case 2:
        return 'التسعير';
      case 3:
        return 'الصور والوسائط';
      case 4:
        return 'التفاصيل والخدمات';
      case 5:
        return 'المراجعة والنشر';
      default:
        return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildSpecificationsStep();
      case 2:
        return _buildPricingStep();
      case 3:
        return _buildMediaStep();
      case 4:
        return _buildDetailsStep();
      case 5:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            icon: Icons.title,
            title: 'المعلومات الأساسية',
            subtitle: 'أدخل المعلومات الأساسية عن المطبخ',
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان الإعلان *',
                    hintText: 'مثال: مطبخ مودرن فاخر - تصميم إيطالي',
                    prefixIcon: const Icon(Icons.article_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCity,
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
                      _selectedCity = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedKitchenType,
                  decoration: InputDecoration(
                    labelText: 'نوع المطبخ *',
                    prefixIcon: const Icon(Icons.kitchen_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _kitchenTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKitchenType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTargetClient,
                  decoration: InputDecoration(
                    labelText: 'العميل المستهدف *',
                    prefixIcon: const Icon(Icons.groups_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _targetClients
                      .map((client) => DropdownMenuItem(
                            value: client,
                            child: Text(client),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTargetClient = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsStep() {
    return Column(
      children: [
        _buildSectionCard(
          icon: Icons.engineering_outlined,
          title: 'المواصفات الفنية',
          subtitle: 'حدد المواصفات الفنية للمطبخ',
          child: Column(
            children: [
              TextFormField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'مساحة المطبخ (متر مربع) *',
                  hintText: 'مثال: 15',
                  prefixIcon: const Icon(Icons.square_foot_outlined),
                  suffixText: 'م²',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _materialsController,
                decoration: InputDecoration(
                  labelText: 'المواد الأساسية *',
                  hintText: 'مثال: خشب طبيعي، MDF، ألمنيوم',
                  prefixIcon: const Icon(Icons.layers_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _completionDaysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'مدة الإنجاز المتوقعة (أيام)',
                  hintText: 'مثال: 30',
                  prefixIcon: const Icon(Icons.schedule_outlined),
                  suffixText: 'يوم',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _warrantyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'الضمان (سنوات)',
                  hintText: 'مثال: 5',
                  prefixIcon: const Icon(Icons.verified_user_outlined),
                  suffixText: 'سنوات',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingStep() {
    return Column(
      children: [
        _buildSectionCard(
          icon: Icons.attach_money_outlined,
          title: 'التسعير',
          subtitle: 'حدد نطاق سعر المطبخ',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceFromController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'السعر من *',
                        hintText: '20000',
                        prefixIcon: const Icon(Icons.money_outlined),
                        suffixText: 'ريال',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceToController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'السعر إلى *',
                        hintText: '40000',
                        prefixIcon: const Icon(Icons.money_outlined),
                        suffixText: 'ريال',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceNotesController,
                decoration: InputDecoration(
                  labelText: 'ملاحظات حول السعر (اختياري)',
                  hintText: 'مثال: السعر شامل التركيب والتوصيل',
                  prefixIcon: const Icon(Icons.note_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
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
                        'نطاق السعر يساعد العملاء في فهم التكلفة المتوقعة',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaStep() {
    return Column(
      children: [
        _buildSectionCard(
          icon: Icons.photo_library_outlined,
          title: 'الصور والوسائط',
          subtitle: 'أضف صور المطبخ (صورة رئيسية + 3-8 صور إضافية)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // زر رفع الصور
              InkWell(
                onTap: () {
                  setState(() {
                    // محاكاة رفع صورة
                    _uploadedImages.add('https://via.placeholder.com/300');
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة الصورة بنجاح')),
                  );
                },
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اضغط لرفع الصور',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PNG, JPG (حد أقصى 5 ميجا)',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_uploadedImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'الصور المرفوعة:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _uploadedImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    return Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 40, color: Colors.grey.shade600),
                              const SizedBox(height: 4),
                              if (index == 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'رئيسية',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _uploadedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              // رفع فيديو
              const Text(
                'فيديو (اختياري)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'رابط الفيديو (يوتيوب)',
                  hintText: 'https://www.youtube.com/watch?v=...',
                  prefixIcon: const Icon(Icons.video_library_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  _videoUrl = value;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      children: [
        _buildSectionCard(
          icon: Icons.description_outlined,
          title: 'التفاصيل والخدمات',
          subtitle: 'أضف وصف مفصل والخدمات المرافقة',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'وصف مفصل للمطبخ *',
                  hintText: 'اكتب وصفاً شاملاً يوضح مميزات المطبخ وتفاصيله...',
                  prefixIcon: const Icon(Icons.text_fields),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 5,
                maxLength: 500,
              ),
              const SizedBox(height: 24),
              const Text(
                'الخدمات المرافقة:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableServices.map((service) {
                  final isSelected = _selectedServices.contains(service);
                  return FilterChip(
                    label: Text(service),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedServices.add(service);
                        } else {
                          _selectedServices.remove(service);
                        }
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      children: [
        _buildSectionCard(
          icon: Icons.preview_outlined,
          title: 'المراجعة والنشر',
          subtitle: 'راجع البيانات قبل النشر',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewItem('العنوان', _titleController.text),
              _buildReviewItem('المدينة', _selectedCity ?? ''),
              _buildReviewItem('نوع المطبخ', _selectedKitchenType ?? ''),
              _buildReviewItem('العميل المستهدف', _selectedTargetClient ?? ''),
              _buildReviewItem('المساحة', '${_areaController.text} م²'),
              _buildReviewItem('المواد', _materialsController.text),
              if (_completionDaysController.text.isNotEmpty)
                _buildReviewItem('مدة الإنجاز', '${_completionDaysController.text} يوم'),
              if (_warrantyController.text.isNotEmpty)
                _buildReviewItem('الضمان', '${_warrantyController.text} سنوات'),
              _buildReviewItem(
                'السعر',
                '${_priceFromController.text} - ${_priceToController.text} ريال',
              ),
              _buildReviewItem('عدد الصور', '${_uploadedImages.length}'),
              if (_videoUrl != null && _videoUrl!.isNotEmpty) _buildReviewItem('فيديو', 'متوفر'),
              if (_selectedServices.isNotEmpty)
                _buildReviewItem('الخدمات', _selectedServices.join(', ')),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              const Text(
                'اختر نوع النشر:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildPlanOption(
                value: 'free',
                title: 'إعلان عادي',
                price: 'مجاني',
                features: [
                  'نشر في القوائم العامة',
                  'يظهر في نتائج البحث',
                  'إحصائيات أساسية',
                ],
                color: Colors.grey.shade700,
              ),
              const SizedBox(height: 12),
              _buildPlanOption(
                value: 'featured',
                title: 'إعلان مميز',
                price: '500 ريال/شهر',
                features: [
                  'ظهور في الصفحة الرئيسية',
                  'علامة "مميز" ذهبية',
                  'أولوية في نتائج البحث',
                  'زيادة الزيارات 300%',
                ],
                color: Colors.amber.shade700,
                recommended: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption({
    required String value,
    required String title,
    required String price,
    required List<String> features,
    required Color color,
    bool recommended = false,
  }) {
    final isSelected = _selectedPlan == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPlan = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedPlan,
              onChanged: (val) {
                setState(() {
                  _selectedPlan = val!;
                });
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (recommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'موصى به',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...features.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 16, color: Colors.green.shade600),
                            const SizedBox(width: 4),
                            Text(f, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('السابق'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep < 5 ? 'التالي' : 'إرسال للمراجعة',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
