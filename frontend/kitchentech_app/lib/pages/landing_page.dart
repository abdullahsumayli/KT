import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/state/auth_state.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _TopBar(),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: isWide
                      ? const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: _HeroSection()),
                            SizedBox(width: 32),
                            Expanded(child: _HeroMockup()),
                          ],
                        )
                      : const Column(
                          children: [
                            _HeroMockup(),
                            SizedBox(height: 24),
                            _HeroSection(),
                          ],
                        ),
                ),
                const SizedBox(height: 40),
                const _SectionDivider(),
                const SizedBox(height: 32),
                const _WhyKitchenTechSection(),
                const SizedBox(height: 40),
                const _HowItWorksSection(),
                const SizedBox(height: 40),
                const _ExtraServicesSection(),
                const SizedBox(height: 40),
                const _CTASection(),
                const SizedBox(height: 24),
                const _Footer(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // الشعار
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.deepOrange.shade400,
                      Colors.brown.shade700,
                    ],
                  ),
                ),
                child: const Icon(Icons.kitchen, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'كتشن تك',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'منصة المطابخ الذكية في السعودية',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // روابط سريعة
          TextButton(
            onPressed: () {
              // تمرير للأسفل لاحقًا إن حبيت
            },
            child: const Text('المميزات'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/listings');
            },
            child: const Text('تصفّح المطابخ'),
          ),
          TextButton(
            onPressed: () {
              final authState = context.read<AuthState>();
              if (authState.isLoggedIn) {
                Navigator.of(context).pushNamed('/my-listings');
              } else {
                Navigator.of(context).pushNamed('/login');
              }
            },
            child: const Text('إعلاناتي'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              final authState = context.read<AuthState>();
              if (authState.isLoggedIn) {
                Navigator.of(context).pushNamed('/add-listing');
              } else {
                Navigator.of(context).pushNamed('/login');
              }
            },
            child: const Text('أضف مطبخك الآن'),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كتشن تك\nمنصة المطابخ الذكية',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'بيع وشراء وتصميم وتركيب المطابخ في مكان واحد.\n'
          'كتشن تك تربطك بأفضل عروض المطابخ في السعودية وتستخدم الذكاء الاصطناعي لكتابة الوصف، اقتراح السعر، ومساعدتك في اتخاذ قرار الشراء.',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.7,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              onPressed: () {
                final authState = context.read<AuthState>();
                if (authState.isLoggedIn) {
                  Navigator.of(context).pushNamed('/add-listing');
                } else {
                  Navigator.of(context).pushNamed('/login');
                }
              },
              label: const Text('أضف مطبخك خلال 60 ثانية'),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).pushNamed('/listings');
              },
              label: const Text('تصفّح المطابخ المتاحة'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.verified, size: 18, color: Colors.green[600]),
            const SizedBox(width: 6),
            Text(
              'منصة متخصصة للمطابخ فقط — لا تضيع في زحمة الإعلانات العامة.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroMockup extends StatelessWidget {
  const _HeroMockup();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.brown.shade800,
              Colors.brown.shade500,
              Colors.deepOrange.shade300,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'مدعوم بالذكاء الاصطناعي',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Text(
              'صوّر مطبخك…\nودَع كتشن تك يكتب الإعلان ويقترح السعر.',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            Text(
              'وصف احترافي، تسعير ذكي، وخدمات فك وتركيب من فنيين موثوقين.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.deepOrange.shade200,
        ),
      ),
    );
  }
}

class _WhyKitchenTechSection extends StatelessWidget {
  const _WhyKitchenTechSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لماذا كتشن تك؟',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _FeatureCard(
                icon: Icons.grid_view_rounded,
                title: 'منصة متخصصة للمطابخ فقط',
                body:
                    'مطابخ تفصيل، جاهزة، جديدة، مستعملة، مودرن وكلاسيك. كل شيء في منصة واحدة موجهة للمطابخ فقط.',
              ),
              _FeatureCard(
                icon: Icons.auto_awesome,
                title: 'ذكاء اصطناعي يجهز إعلانك',
                body:
                    'نكتب وصفًا احترافيًا، ونقترح سعرًا مناسبًا بناءً على سوق مدينتك ونوع المطبخ وحالته.',
              ),
              _FeatureCard(
                icon: Icons.bolt,
                title: 'إعلانك جاهز خلال أقل من دقيقة',
                body:
                    'ارفع الصور، اختر بعض الخيارات، ودَع كتشن تك يكمل التفاصيل الباقية بدلاً عنك.',
              ),
              _FeatureCard(
                icon: Icons.filter_alt,
                title: 'بحث وفلترة للمشتري الجاد',
                body:
                    'يمكنك الفلترة حسب المدينة، الميزانية، الحالة، المواد، والأسلوب للوصول للمطبخ المناسب بسرعة.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'كيف تعمل كتشن تك؟',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StepCard(
                icon: Icons.storefront,
                title: 'للبائع',
                bullets: [
                  'إنشئ حسابك واملأ بيانات بسيطة.',
                  'صوّر مطبخك من عدة زوايا وارفع الصور.',
                  'دع النظام يكتب الوصف ويقترح السعر.',
                  'انشر إعلانك وفعّل خيار الترقية لزيادة الظهور.',
                ],
              ),
              _StepCard(
                icon: Icons.shopping_bag,
                title: 'للمشتري',
                bullets: [
                  'تصفّح المطابخ في مدينتك أو حولك.',
                  'فلتر حسب الميزانية، النوع، والمواد.',
                  'شاهد الصور والوصف الواضح قبل الاتصال.',
                  'تواصل مباشرة مع البائع أو اطلب فني تركيب.',
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExtraServicesSection extends StatelessWidget {
  const _ExtraServicesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'خدمات إضافية حول مطبخك',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _FeatureCard(
                icon: Icons.design_services,
                title: 'استشارة تصميم مطبخ',
                body:
                    'ارفع مخطط مطبخك واحصل على اقتراح تصميم مبدئي يساعدك تتخيل النتيجة قبل التنفيذ.',
              ),
              _FeatureCard(
                icon: Icons.build,
                title: 'فك ونقل وتركيب',
                body: 'شبكة فنيين مختصين لخدمة فك المطابخ ونقلها وتركيبها في مدينتك.',
              ),
              _FeatureCard(
                icon: Icons.analytics,
                title: 'تقدير سعر مطبخك',
                body:
                    'أداة تقدير سعر مدعومة بالبيانات تساعدك تعرف السعر العادل قبل البيع أو الشراء.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CTASection extends StatelessWidget {
  const _CTASection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.deepOrange.shade50,
        ),
        child: Column(
          children: [
            Text(
              'جاهز تبدأ مع كتشن تك؟',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف مطبخك الآن أو استكشف أفضل العروض المتاحة في مدينتك.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final authState = context.read<AuthState>();
                    if (authState.isLoggedIn) {
                      Navigator.of(context).pushNamed('/add-listing');
                    } else {
                      Navigator.of(context).pushNamed('/login');
                    }
                  },
                  child: const Text('أضف مطبخك الآن'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/listings');
                  },
                  child: const Text('تصفّح المطابخ المعروضة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          '© ${DateTime.now().year} كتشن تك – KitchenTech',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'منصة المطابخ الذكية في السعودية',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 270,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: Colors.deepOrange.shade400),
              const SizedBox(height: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> bullets;

  const _StepCard({
    required this.icon,
    required this.title,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 340,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: Colors.deepOrange.shade400),
              const SizedBox(height: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...bullets.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(
                        child: Text(
                          b,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
