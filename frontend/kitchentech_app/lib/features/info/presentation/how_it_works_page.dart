import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('كيف يعمل التطبيق'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.kitchen_outlined,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'مرحباً بك في كيتشن تك',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'المنصة الأولى لبيع وشراء المطابخ في المملكة',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // For Buyers Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 32,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'للباحثين عن المطابخ',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildStep(
                    context,
                    number: '1',
                    title: 'تصفح المطابخ',
                    description:
                        'ابحث عن المطبخ المثالي من بين مئات الخيارات المتاحة. استخدم الفلاتر للبحث حسب النوع، المدينة، والسعر.',
                    icon: Icons.search,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 16),

                  _buildStep(
                    context,
                    number: '2',
                    title: 'عرض التفاصيل',
                    description:
                        'اطلع على صور المطبخ، المواصفات الكاملة، والأسعار. تعرف على تقييمات المعلنين السابقة.',
                    icon: Icons.info_outline,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 16),

                  _buildStep(
                    context,
                    number: '3',
                    title: 'تواصل مع المعلن',
                    description:
                        'اتصل مباشرة عبر الهاتف أو واتساب للاستفسار والتفاوض. كل المعلومات متوفرة بكبسة زر.',
                    icon: Icons.phone_outlined,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 16),

                  _buildStep(
                    context,
                    number: '4',
                    title: 'أضف للمفضلة',
                    description:
                        'احفظ المطابخ التي أعجبتك في قائمة المفضلة للرجوع إليها لاحقاً واتخاذ القرار المناسب.',
                    icon: Icons.favorite_outline,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 32),
                  Center(
                    child: FilledButton.icon(
                      onPressed: () {
                        context.go('/kitchens');
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('ابدأ البحث الآن'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                  const Divider(),
                  const SizedBox(height: 32),

                  // For Advertisers Section
                  Row(
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 32,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'للمعلنين والباعة',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildStep(
                    context,
                    number: '1',
                    title: 'إنشاء حساب معلن',
                    description:
                        'سجل كمعلن مع تعبئة بيانات شركتك أو معرضك. أدخل معلومات التواصل الكاملة لسهولة الوصول إليك.',
                    icon: Icons.person_add_outlined,
                    colorScheme: colorScheme,
                    isSecondary: true,
                  ),
                  const SizedBox(height: 16),

                  _buildStep(
                    context,
                    number: '2',
                    title: 'اختر باقتك المناسبة',
                    description:
                        'اختر من بين باقاتنا المتنوعة (الأساسية، المميزة، الاحترافية). كل باقة مصممة لتناسب احتياجاتك وميزانيتك.',
                    icon: Icons.card_membership_outlined,
                    colorScheme: colorScheme,
                    isSecondary: true,
                  ),
                  const SizedBox(height: 16),

                  _buildStep(
                    context,
                    number: '3',
                    title: 'أضف إعلاناتك',
                    description:
                        'ارفع صور المطابخ عالية الجودة، أضف الأسعار والمواصفات الكاملة. استخدم معالج الإضافة السهل خطوة بخطوة.',
                    icon: Icons.add_photo_alternate_outlined,
                    colorScheme: colorScheme,
                    isSecondary: true,
                  ),
                  const SizedBox(height: 16),

                  _buildStep(
                    context,
                    number: '4',
                    title: 'تابع أداءك',
                    description:
                        'استخدم لوحة التحكم المتقدمة لمتابعة مشاهدات إعلاناتك، عدد التواصلات، وتحديث المحتوى بسهولة.',
                    icon: Icons.analytics_outlined,
                    colorScheme: colorScheme,
                    isSecondary: true,
                  ),

                  const SizedBox(height: 32),
                  Center(
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        context.go('/plans');
                      },
                      icon: const Icon(Icons.rocket_launch),
                      label: const Text('ابدأ الإعلان الآن'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Features Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مميزات المنصة',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFeature(
                          icon: Icons.verified_user_outlined,
                          title: 'موثوق وآمن',
                          description: 'جميع المعلنين موثقون ومعتمدون',
                        ),
                        const SizedBox(height: 12),
                        _buildFeature(
                          icon: Icons.speed_outlined,
                          title: 'سريع وسهل',
                          description: 'واجهة بسيطة وسريعة للبحث والإعلان',
                        ),
                        const SizedBox(height: 12),
                        _buildFeature(
                          icon: Icons.support_agent_outlined,
                          title: 'دعم فني',
                          description: 'فريق دعم متاح للمساعدة في أي وقت',
                        ),
                        const SizedBox(height: 12),
                        _buildFeature(
                          icon: Icons.mobile_friendly_outlined,
                          title: 'متوافق مع جميع الأجهزة',
                          description: 'يعمل على الجوال والتابلت والكمبيوتر',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // CTA Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.1),
                          colorScheme.secondary.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.question_answer_outlined,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'هل لديك أسئلة؟',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'تواصل معنا وسنكون سعداء بمساعدتك',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            context.go('/contact');
                          },
                          icon: const Icon(Icons.contact_support_outlined),
                          label: const Text('اتصل بنا'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required ColorScheme colorScheme,
    bool isSecondary = false,
  }) {
    final theme = Theme.of(context);
    final accentColor = isSecondary ? colorScheme.secondary : colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number Badge
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: accentColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
