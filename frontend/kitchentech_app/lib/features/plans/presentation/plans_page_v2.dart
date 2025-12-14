import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Spec 2.7: صفحة الباقات (Plans Page)
/// عرض احترافي للباقات المتاحة للمعلنين
class PlansPageV2 extends StatelessWidget {
  const PlansPageV2({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('باقات الاشتراك'),
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
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isWide ? 60 : 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      Text(
                        'اختر الباقة المناسبة لك',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'باقات مرنة تناسب احتياجاتك وميزانيتك',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Monthly/Yearly Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildToggleButton(
                              context,
                              'شهري',
                              true,
                              () {},
                            ),
                            _buildToggleButton(
                              context,
                              'سنوي (خصم 20%)',
                              false,
                              () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Plans Grid
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildPlanCard(
                                context,
                                title: 'الباقة المجانية',
                                price: '0',
                                period: 'مجاناً للأبد',
                                features: [
                                  'حتى 3 إعلانات',
                                  'لا يوجد تمييز في الصفحة الرئيسية',
                                  'دعم فني أساسي',
                                  'صلاحية غير محدودة',
                                ],
                                isPopular: false,
                                buttonText: 'البدء مجاناً',
                                buttonColor: Colors.grey[700]!,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildPlanCard(
                                context,
                                title: 'الباقة الأساسية',
                                price: '299',
                                period: 'شهرياً',
                                features: [
                                  'حتى 15 إعلان',
                                  '3 إعلانات مميزة',
                                  'أولوية ظهور متوسطة',
                                  'دعم فني سريع',
                                  'إحصائيات مفصلة',
                                ],
                                isPopular: false,
                                buttonText: 'اختر هذه الباقة',
                                buttonColor: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildPlanCard(
                                context,
                                title: 'الباقة الاحترافية',
                                price: '599',
                                period: 'شهرياً',
                                features: [
                                  'إعلانات غير محدودة',
                                  '10 إعلانات مميزة',
                                  'أولوية ظهور عالية',
                                  'دعم فني مخصص 24/7',
                                  'إحصائيات متقدمة وتقارير',
                                  'شارة "معلن موثوق"',
                                  'عرض في الصفحة الرئيسية',
                                ],
                                isPopular: true,
                                buttonText: 'اختر هذه الباقة',
                                buttonColor: const Color(0xFFFF9800),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildPlanCard(
                              context,
                              title: 'الباقة المجانية',
                              price: '0',
                              period: 'مجاناً للأبد',
                              features: [
                                'حتى 3 إعلانات',
                                'لا يوجد تمييز في الصفحة الرئيسية',
                                'دعم فني أساسي',
                                'صلاحية غير محدودة',
                              ],
                              isPopular: false,
                              buttonText: 'البدء مجاناً',
                              buttonColor: Colors.grey[700]!,
                            ),
                            const SizedBox(height: 24),
                            _buildPlanCard(
                              context,
                              title: 'الباقة الأساسية',
                              price: '299',
                              period: 'شهرياً',
                              features: [
                                'حتى 15 إعلان',
                                '3 إعلانات مميزة',
                                'أولوية ظهور متوسطة',
                                'دعم فني سريع',
                                'إحصائيات مفصلة',
                              ],
                              isPopular: false,
                              buttonText: 'اختر هذه الباقة',
                              buttonColor: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 24),
                            _buildPlanCard(
                              context,
                              title: 'الباقة الاحترافية',
                              price: '599',
                              period: 'شهرياً',
                              features: [
                                'إعلانات غير محدودة',
                                '10 إعلانات مميزة',
                                'أولوية ظهور عالية',
                                'دعم فني مخصص 24/7',
                                'إحصائيات متقدمة وتقارير',
                                'شارة "معلن موثوق"',
                                'عرض في الصفحة الرئيسية',
                              ],
                              isPopular: true,
                              buttonText: 'اختر هذه الباقة',
                              buttonColor: const Color(0xFFFF9800),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 60),

            // Features Comparison Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isWide ? 60 : 24),
              color: Colors.white,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      Text(
                        'مقارنة الميزات',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildComparisonTable(context, isWide),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // FAQ Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isWide ? 60 : 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Text(
                        'الأسئلة الشائعة',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildFAQItem(
                        'هل يمكنني تغيير الباقة لاحقاً؟',
                        'نعم، يمكنك الترقية أو التخفيض في أي وقت. سيتم حساب المبلغ بشكل تناسبي.',
                      ),
                      const SizedBox(height: 16),
                      _buildFAQItem(
                        'ما هي وسائل الدفع المتاحة؟',
                        'نقبل بطاقات مدى، فيزا، ماستركارد، وSTC Pay.',
                      ),
                      const SizedBox(height: 16),
                      _buildFAQItem(
                        'هل يمكنني إلغاء الاشتراك؟',
                        'نعم، يمكنك إلغاء الاشتراك في أي وقت دون أي رسوم إضافية.',
                      ),
                      const SizedBox(height: 16),
                      _buildFAQItem(
                        'ماذا يحدث عند انتهاء الباقة؟',
                        'سيتم تجديد الاشتراك تلقائياً ما لم تقم بإلغائه قبل تاريخ التجديد.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isPopular,
    required String buttonText,
    required Color buttonColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? const Color(0xFFFF9800) : Colors.grey[200]!,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Popular Badge
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFF9800),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: const Center(
                child: Text(
                  '⭐ الأكثر شعبية',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: buttonColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'ريال',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  period,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to checkout with plan details
                      context.push(
                        '/checkout',
                        extra: {
                          'planTitle': title,
                          'planPrice': price,
                          'planPeriod': period,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Features
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: buttonColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                              ),
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
    );
  }

  Widget _buildComparisonTable(BuildContext context, bool isWide) {
    return SingleChildScrollView(
      scrollDirection: isWide ? Axis.vertical : Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(color: Colors.grey[300]!),
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[100]),
            children: [
              _buildTableCell('الميزة', isHeader: true),
              _buildTableCell('مجانية', isHeader: true),
              _buildTableCell('أساسية', isHeader: true),
              _buildTableCell('احترافية', isHeader: true),
            ],
          ),
          _buildComparisonRow('عدد الإعلانات', '3', '15', 'غير محدود'),
          _buildComparisonRow('إعلانات مميزة', '0', '3', '10'),
          _buildComparisonRow('أولوية الظهور', '❌', '✓', '✓✓'),
          _buildComparisonRow('دعم فني', 'أساسي', 'سريع', '24/7'),
          _buildComparisonRow('إحصائيات', '❌', '✓', '✓✓'),
          _buildComparisonRow('شارة موثوق', '❌', '❌', '✓'),
          _buildComparisonRow('عرض رئيسي', '❌', '❌', '✓'),
        ],
      ),
    );
  }

  TableRow _buildComparisonRow(
    String feature,
    String free,
    String basic,
    String pro,
  ) {
    return TableRow(
      children: [
        _buildTableCell(feature, isFeature: true),
        _buildTableCell(free),
        _buildTableCell(basic),
        _buildTableCell(pro),
      ],
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isFeature = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader || isFeature ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.black87 : Colors.black54,
        ),
        textAlign: isFeature ? TextAlign.start : TextAlign.center,
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          answer,
          style: TextStyle(
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
