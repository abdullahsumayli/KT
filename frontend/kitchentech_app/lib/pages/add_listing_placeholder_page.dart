import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../features/auth/state/auth_state.dart';
import '../features/listings/data/listing_images_api.dart';
import '../features/listings/data/listings_api.dart';

class AddListingPlaceholderPage extends StatefulWidget {
  const AddListingPlaceholderPage({super.key});

  @override
  State<AddListingPlaceholderPage> createState() => _AddListingPlaceholderPageState();
}

class _AddListingPlaceholderPageState extends State<AddListingPlaceholderPage> {
  final _formKey = GlobalKey<FormState>();
  final _api = ListingsApi();
  final _imagesApi = ListingImagesApi();

  // Controllers
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  // Dropdowns
  String _selectedType = 'جديد';
  String _selectedMaterial = 'خشب';

  bool _isLoading = false;

  // Image upload state
  List<Uint8List> _selectedImagesBytes = [];
  List<String> _selectedFileNames = [];

  final Map<String, String> _typeMap = {
    'جديد': 'new',
    'مستعمل': 'used',
    'جاهز': 'ready',
    'تفصيل': 'custom',
  };

  final Map<String, String> _materialMap = {
    'خشب': 'wood',
    'ألمنيوم': 'aluminum',
    'مختلط': 'mixed',
    'غير محدد': 'unknown',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = context.read<AuthState>();
      final listing = await _api.createListing(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        city: _cityController.text.trim(),
        type: _typeMap[_selectedType]!,
        material: _materialMap[_selectedMaterial]!,
        lengthM: _lengthController.text.isNotEmpty ? double.tryParse(_lengthController.text) : null,
        widthM: _widthController.text.isNotEmpty ? double.tryParse(_widthController.text) : null,
        heightM: _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : null,
        token: authState.token,
      );

      // Upload images if any selected
      if (_selectedImagesBytes.isNotEmpty && authState.token != null) {
        try {
          await _imagesApi.uploadImages(
            listingId: listing.id.toString(),
            filesBytes: _selectedImagesBytes,
            fileNames: _selectedFileNames,
            token: authState.token!,
          );
        } catch (imageError) {
          // Log error but don't fail the whole operation
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ تم إضافة المطبخ لكن فشل رفع الصور: $imageError'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم إضافة المطبخ بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushReplacementNamed('/listings');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل إضافة المطبخ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateDescription() async {
    // Validate required fields
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال عنوان المطبخ أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال المدينة أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري توليد الوصف...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final authState = context.read<AuthState>();
      final description = await _api.generateDescription(
        title: _titleController.text.trim(),
        city: _cityController.text.trim(),
        type: _typeMap[_selectedType]!,
        material: _materialMap[_selectedMaterial]!,
        price: _priceController.text.isNotEmpty ? double.tryParse(_priceController.text) : null,
        notes: null,
        token: authState.token,
      );

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Update description field
      setState(() {
        _descriptionController.text = description;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم توليد الوصف تلقائيًا'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل توليد الوصف: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImagesBytes =
              result.files.where((file) => file.bytes != null).map((file) => file.bytes!).toList();
          _selectedFileNames =
              result.files.where((file) => file.name.isNotEmpty).map((file) => file.name).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم اختيار ${_selectedImagesBytes.length} صورة'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل اختيار الصور: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مطبخ جديد'),
        backgroundColor: Colors.deepOrange.shade50,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'املأ بيانات المطبخ',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أضف تفاصيل المطبخ لعرضه على المنصة',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان *',
                        hintText: 'مثال: مطبخ خشب أبيض مودرن',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال عنوان المطبخ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price field
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'السعر (ر.س) *',
                        hintText: 'مثال: 15000',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال السعر';
                        }
                        if (double.tryParse(value) == null) {
                          return 'الرجاء إدخال سعر صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // City field
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'المدينة *',
                        hintText: 'مثال: الرياض',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال المدينة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Type dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'نوع المطبخ *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _typeMap.keys.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value ?? 'جديد';
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Material dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMaterial,
                      decoration: const InputDecoration(
                        labelText: 'المادة *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.layers),
                      ),
                      items: _materialMap.keys.map((material) {
                        return DropdownMenuItem(value: material, child: Text(material));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMaterial = value ?? 'خشب';
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Dimensions section
                    Text(
                      'الأبعاد (اختياري)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _lengthController,
                            decoration: const InputDecoration(
                              labelText: 'الطول (م)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.straighten),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _widthController,
                            decoration: const InputDecoration(
                              labelText: 'العرض (م)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.width_normal),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            decoration: const InputDecoration(
                              labelText: 'الارتفاع (م)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.height),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'الوصف *',
                        hintText: 'اكتب وصفًا تفصيليًا للمطبخ...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال وصف المطبخ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Auto-generate description button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _generateDescription,
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: const Text('اكتب الوصف تلقائيًا'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepOrange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Image upload section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.image, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'صور المطبخ',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: Text(_selectedImagesBytes.isEmpty
                                ? 'اختر صور المطبخ'
                                : 'تم اختيار ${_selectedImagesBytes.length} صورة'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                          if (_selectedImagesBytes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImagesBytes.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    margin: const EdgeInsets.only(left: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        _selectedImagesBytes[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('جاري الحفظ...'),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save),
                                SizedBox(width: 8),
                                Text('حفظ الإعلان'),
                              ],
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
}
