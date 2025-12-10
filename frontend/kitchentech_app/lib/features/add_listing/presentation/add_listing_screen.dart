import 'package:flutter/material.dart';

import '../../../shared/widgets/shared_widgets.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  String selectedType = 'جاهز';
  String selectedCity = 'الرياض';
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isGeneratingDescription = false;
  bool isGeneratingPrice = false;
  List<String> selectedImages = [];

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _generateAiDescription() async {
    setState(() {
      isGeneratingDescription = true;
    });

    await Future.delayed(const Duration(seconds: 2)); // Mock API call

    setState(() {
      _descriptionController.text = 'مطبخ عصري بتصميم حديث مع خامات عالية الجودة...';
      isGeneratingDescription = false;
    });
  }

  Future<void> _suggestPrice() async {
    setState(() {
      isGeneratingPrice = true;
    });

    await Future.delayed(const Duration(seconds: 2)); // Mock API call

    setState(() {
      _priceController.text = '42000';
      isGeneratingPrice = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('أضف إعلان'),
            const SizedBox(width: 8),
            Image.asset(
              'assets/images/logo.png',
              height: 28,
              fit: BoxFit.contain,
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Type Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'نوع الإعلان',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.end,
                        children: ['جاهز', 'تفصيل'].map((type) {
                          return FilterChip(
                            label: Text(type),
                            selected: selectedType == type,
                            onSelected: (selected) {
                              setState(() {
                                selectedType = type;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'الموقع',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCity,
                        decoration: const InputDecoration(
                          labelText: 'المدينة',
                          alignLabelWithHint: true,
                        ),
                        alignment: Alignment.centerRight,
                        items: ['الرياض', 'جدة', 'الدمام', 'مكة', 'المدينة']
                            .map((city) => DropdownMenuItem(
                                  value: city,
                                  alignment: Alignment.centerRight,
                                  child: Text(city),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCity = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Price Section with AI Suggestion
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'السعر',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          labelText: 'السعر (ر.س)',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال السعر';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      SecondaryButton(
                        onPressed: isGeneratingPrice ? null : _suggestPrice,
                        text: 'اقتراح السعر بالذكاء الاصطناعي',
                        icon: Icons.psychology_rounded,
                        isLoading: isGeneratingPrice,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Photos Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'الصور',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: selectedImages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == selectedImages.length) {
                            return InkWell(
                              onTap: () {
                                // Open image picker
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    style: BorderStyle.solid,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description Section with AI
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'الوصف',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          labelText: 'وصف المطبخ',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال وصف المطبخ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      SecondaryButton(
                        onPressed: isGeneratingDescription ? null : _generateAiDescription,
                        text: 'إنشاء وصف بالذكاء الاصطناعي',
                        icon: Icons.auto_awesome,
                        isLoading: isGeneratingDescription,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              PrimaryButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Submit form
                  }
                },
                text: 'نشر الإعلان',
                icon: Icons.check,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
