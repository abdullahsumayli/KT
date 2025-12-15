import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/shared_widgets.dart';
import '../../listings/presentation/widgets/kitchen_card.dart';

class AiWizardScreen extends StatefulWidget {
  const AiWizardScreen({super.key});

  @override
  State<AiWizardScreen> createState() => _AiWizardScreenState();
}

class _AiWizardScreenState extends State<AiWizardScreen> {
  int currentStep = 0;
  String? selectedBudget;
  String? selectedStyle;
  String? selectedReadiness;
  String? selectedCity;
  bool isLoading = false;

  final List<Map<String, dynamic>> recommendations = [
    {
      'id': '1',
      'title': 'مطبخ حديث مع جزيرة',
      'city': 'الرياض',
      'price': 45000.0,
      'type': 'جاهز',
      'aiScore': 9.8,
      'imageUrl': 'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=800&h=600&fit=crop',
    },
    {
      'id': '2',
      'title': 'مطبخ عصري تفصيل',
      'city': 'الرياض',
      'price': 3500.0,
      'type': 'تفصيل',
      'aiScore': 9.5,
      'imageUrl': 'https://images.unsplash.com/photo-1556909172-54557c7e4fb7?w=800&h=600&fit=crop',
    },
  ];

  void _nextStep() {
    if (currentStep < 3) {
      setState(() {
        currentStep++;
      });
    } else {
      _generateRecommendations();
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  Future<void> _generateRecommendations() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2)); // Mock API call

    setState(() {
      isLoading = false;
      currentStep = 4; // Results step
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
            const Text('مساعد الذكاء الاصطناعي'),
            const SizedBox(width: 8),
            Image.asset(
              'assets/brand/logo_mark.png',
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/logosouq.png',
                  height: 28,
                  fit: BoxFit.contain,
                );
              },
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 24),
                  Text(
                    'جاري البحث عن أفضل الخيارات...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Progress Indicator
                if (currentStep < 4)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      children: List.generate(
                        4,
                        (index) => Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(
                              left: index < 3 ? 8 : 0,
                            ),
                            decoration: BoxDecoration(
                              color: index <= currentStep
                                  ? const Color(0xFF2962FF)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildStepContent(),
                  ),
                ),

                // Navigation Buttons
                if (currentStep < 4)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (currentStep > 0)
                          Expanded(
                            child: SecondaryButton(
                              onPressed: _previousStep,
                              text: 'السابق',
                              icon: Icons.arrow_forward,
                            ),
                          ),
                        if (currentStep > 0) const SizedBox(width: 12),
                        Expanded(
                          flex: currentStep == 0 ? 1 : 1,
                          child: PrimaryButton(
                            onPressed: _canProceed() ? _nextStep : null,
                            text: currentStep == 3 ? 'ابحث' : 'التالي',
                            icon: currentStep == 3 ? Icons.search : Icons.arrow_back,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  bool _canProceed() {
    switch (currentStep) {
      case 0:
        return selectedBudget != null;
      case 1:
        return selectedStyle != null;
      case 2:
        return selectedReadiness != null;
      case 3:
        return selectedCity != null;
      default:
        return false;
    }
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildBudgetStep();
      case 1:
        return _buildStyleStep();
      case 2:
        return _buildReadinessStep();
      case 3:
        return _buildCityStep();
      case 4:
        return _buildResultsStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBudgetStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'ما هي ميزانيتك؟',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'اختر النطاق السعري المناسب لك',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ...[
              'أقل من 30,000 ر.س',
              '30,000 - 50,000 ر.س',
              '50,000 - 80,000 ر.س',
              'أكثر من 80,000 ر.س',
            ].map((budget) => _buildOptionTile(
                  budget,
                  selectedBudget == budget,
                  () => setState(() => selectedBudget = budget),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'ما هو أسلوبك المفضل؟',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'اختر التصميم الذي يناسب ذوقك',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ...[
              'حديث وعصري',
              'كلاسيكي',
              'ريفي',
              'صناعي (Industrial)',
            ].map((style) => _buildOptionTile(
                  style,
                  selectedStyle == style,
                  () => setState(() => selectedStyle = style),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildReadinessStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'هل تبحث عن مطبخ جاهز أم حسب الطلب؟',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...[
              'جاهز',
              'حسب الطلب (تفصيل)',
            ].map((readiness) => _buildOptionTile(
                  readiness,
                  selectedReadiness == readiness,
                  () => setState(() => selectedReadiness = readiness),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCityStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'في أي مدينة تبحث؟',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...[
              'الرياض',
              'جدة',
              'الدمام',
              'مكة',
              'المدينة',
            ].map((city) => _buildOptionTile(
                  city,
                  selectedCity == city,
                  () => setState(() => selectedCity = city),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'وجدنا لك أفضل الخيارات',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.psychology_rounded,
                      color: Color(0xFF2962FF),
                      size: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'بناءً على تفضيلاتك: $selectedBudget، $selectedStyle، $selectedReadiness في $selectedCity',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            final kitchen = recommendations[index];
            return KitchenCard(
              id: kitchen['id'],
              title: kitchen['title'],
              city: kitchen['city'],
              price: kitchen['price'],
              type: kitchen['type'],
              aiScore: kitchen['aiScore'],
              imageUrl: kitchen['imageUrl'],
            );
          },
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          onPressed: () {
            context.go('/kitchens');
          },
          text: 'عرض جميع النتائج',
          icon: Icons.arrow_back,
        ),
      ],
    );
  }

  Widget _buildOptionTile(String title, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? const Color(0xFF2962FF) : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
            color: selected ? const Color(0xFF2962FF).withValues(alpha: 0.1) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? const Color(0xFF2962FF) : Colors.grey,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? const Color(0xFF2962FF) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
