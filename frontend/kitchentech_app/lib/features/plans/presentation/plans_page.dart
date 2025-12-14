import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/data/models/plan.dart';

/// صفحة عرض خطط الاشتراك للمعلنين
class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  int _selectedPlanIndex = 1; // Basic plan selected by default

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('خطط الاشتراك'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2962FF), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'اختر الخطة المناسبة لك',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ابدأ في عرض مطابخك وزيادة مبيعاتك',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Plans Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(
                  MockPlans.all.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildPlanCard(
                      MockPlans.all[index],
                      index,
                      isSelected: _selectedPlanIndex == index,
                      onTap: () {
                        setState(() {
                          _selectedPlanIndex = index;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Features Comparison
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'مقارنة الميزات',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureComparison(
                        'عدد الإعلانات',
                        [
                          '${MockPlans.all[0].maxAds}',
                          '${MockPlans.all[1].maxAds}',
                          '${MockPlans.all[2].maxAds}'
                        ],
                      ),
                      _buildFeatureComparison(
                        'إعلانات مميزة',
                        [
                          '${MockPlans.all[0].featuredSlots}',
                          '${MockPlans.all[1].featuredSlots}',
                          '${MockPlans.all[2].featuredSlots}'
                        ],
                      ),
                      _buildFeatureComparison(
                        'أولوية في النتائج',
                        [
                          MockPlans.all[0].priorityRanking ? '✓' : '✗',
                          MockPlans.all[1].priorityRanking ? '✓' : '✗',
                          MockPlans.all[2].priorityRanking ? '✓' : '✗'
                        ],
                        highlights: [
                          MockPlans.all[0].priorityRanking,
                          MockPlans.all[1].priorityRanking,
                          MockPlans.all[2].priorityRanking
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
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
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              final selectedPlan = MockPlans.all[_selectedPlanIndex];
              _showCheckoutDialog(selectedPlan);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'اشترك في ${MockPlans.all[_selectedPlanIndex].nameAr}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(Plan plan, int index,
      {required bool isSelected, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final isPopular = index == 1; // Basic plan is popular

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            // Popular Badge
            if (isPopular)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber[700],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                child: const Text(
                  'الأكثر شعبية',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Plan Name
                  Text(
                    plan.nameAr,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.monthlyPrice == 0 ? 'مجاني' : plan.monthlyPrice.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (plan.monthlyPrice > 0) ...[
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'ر.س/شهري',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    plan.descriptionAr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Features List
                  ...plan.features.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
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

  Widget _buildFeatureComparison(String feature, List<String> values, {List<bool>? highlights}) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            feature,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(3, (index) {
              final isHighlighted = highlights?[index] ?? false;
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    values[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                      color: isHighlighted ? theme.colorScheme.primary : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(Plan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الاشتراك'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أنت على وشك الاشتراك في:'),
            const SizedBox(height: 16),
            Text(
              plan.nameAr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan.monthlyPrice == 0
                  ? 'مجاني'
                  : '${plan.monthlyPrice.toStringAsFixed(0)} ر.س شهرياً',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ملاحظة: هذا نظام تجريبي. لم يتم تفعيل بوابة الدفع بعد.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
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
                SnackBar(
                  content: Text('تم الاشتراك في ${plan.nameAr} بنجاح!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              // Navigate to dashboard after subscription
              final router = GoRouter.of(context);
              Future.delayed(const Duration(seconds: 2), () {
                router.go('/dashboard');
              });
            },
            child: const Text('تأكيد الاشتراك'),
          ),
        ],
      ),
    );
  }
}
