import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Spec 2.9: صفحة كيف تعمل المنصة (How it Works)
/// شرح مبسط للعملاء والمعلنين عن آلية عمل المنصة
class HowItWorksPageV2 extends StatelessWidget {
  const HowItWorksPageV2({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('كيف تعمل المنصة؟'),
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
            // Hero Section
            _buildHeroSection(context, theme, isWide),

            // For Clients Section
            _buildForClientsSection(context, theme, isWide),

            // Divider
            const SizedBox(height: 60),
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 60),

            // For Advertisers Section
            _buildForAdvertisersSection(context, theme, isWide),

            // CTA Section
            _buildCTASection(context, theme, isWide),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, ThemeData theme, bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 80 : 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.kitchen,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'كيف تعمل منصة كيتشن تك؟',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'نربط بين العملاء الباحثين عن مطابخ مميزة\nوالشركات المتخصصة في تصميم وتنفيذ المطابخ',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForClientsSection(BuildContext context, ThemeData theme, bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 60 : 32),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.blue[700],
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'للعميل',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      Text(
                        'ابحث عن مطبخ أحلامك بسهولة',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Steps
              isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildClientStep(
                            context,
                            number: '1',
                            icon: Icons.search,
                            title: 'ابحث عن مطبخك',
                            description: 'استكشف مئات التصاميم المتنوعة من أفضل الشركات في مدينتك',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildClientStep(
                            context,
                            number: '2',
                            icon: Icons.compare_arrows,
                            title: 'قارن بين العروض',
                            description: 'قارن الأسعار والتصاميم والميزات واختر الأنسب لك',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildClientStep(
                            context,
                            number: '3',
                            icon: Icons.phone,
                            title: 'تواصل مباشرة',
                            description: 'تواصل مباشرة مع الشركة عبر الهاتف أو واتساب',
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildClientStep(
                          context,
                          number: '1',
                          icon: Icons.search,
                          title: 'ابحث عن مطبخك',
                          description: 'استكشف مئات التصاميم المتنوعة من أفضل الشركات في مدينتك',
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 24),
                        _buildClientStep(
                          context,
                          number: '2',
                          icon: Icons.compare_arrows,
                          title: 'قارن بين العروض',
                          description: 'قارن الأسعار والتصاميم والميزات واختر الأنسب لك',
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 24),
                        _buildClientStep(
                          context,
                          number: '3',
                          icon: Icons.phone,
                          title: 'تواصل مباشرة',
                          description: 'تواصل مباشرة مع الشركة عبر الهاتف أو واتساب',
                          color: Colors.blue,
                        ),
                      ],
                    ),
              const SizedBox(height: 40),

              // CTA Button
              ElevatedButton.icon(
                onPressed: () => context.go('/kitchens'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.search, size: 24),
                label: const Text(
                  'ابدأ البحث الآن',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForAdvertisersSection(BuildContext context, ThemeData theme, bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 60 : 32),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.business,
                      color: Colors.orange[700],
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'للمعلن',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      Text(
                        'وصّل خدماتك لآلاف العملاء',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Steps
              isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildAdvertiserStep(
                            context,
                            number: '1',
                            icon: Icons.app_registration,
                            title: 'سجّل شركتك',
                            description: 'أنشئ حساب مجاني وأضف معلومات شركتك وخدماتك',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildAdvertiserStep(
                            context,
                            number: '2',
                            icon: Icons.add_photo_alternate,
                            title: 'أضف إعلاناتك',
                            description: 'انشر صور مطابخك مع التفاصيل والأسعار بكل سهولة',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildAdvertiserStep(
                            context,
                            number: '3',
                            icon: Icons.people,
                            title: 'احصل على عملاء',
                            description: 'استقبل طلبات العملاء المهتمين مباشرة على جوالك',
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildAdvertiserStep(
                          context,
                          number: '1',
                          icon: Icons.app_registration,
                          title: 'سجّل شركتك',
                          description: 'أنشئ حساب مجاني وأضف معلومات شركتك وخدماتك',
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 24),
                        _buildAdvertiserStep(
                          context,
                          number: '2',
                          icon: Icons.add_photo_alternate,
                          title: 'أضف إعلاناتك',
                          description: 'انشر صور مطابخك مع التفاصيل والأسعار بكل سهولة',
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 24),
                        _buildAdvertiserStep(
                          context,
                          number: '3',
                          icon: Icons.people,
                          title: 'احصل على عملاء',
                          description: 'استقبل طلبات العملاء المهتمين مباشرة على جوالك',
                          color: Colors.orange,
                        ),
                      ],
                    ),
              const SizedBox(height: 40),

              // CTA Button
              ElevatedButton.icon(
                onPressed: () => context.go('/auth/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.business, size: 24),
                label: const Text(
                  'سجّل شركتك الآن',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClientStep(
    BuildContext context, {
    required String number,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Number Badge
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 40,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.6,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertiserStep(
    BuildContext context, {
    required String number,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Number Badge
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 40,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.6,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context, ThemeData theme, bool isWide) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: isWide ? 60 : 24),
      padding: EdgeInsets.all(isWide ? 60 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            Colors.blue[50]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.rocket_launch,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'هل أنت جاهز للبدء؟',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'انضم إلى آلاف العملاء والشركات الذين يثقون بمنصتنا',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Buttons
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  // For Clients
                  ElevatedButton.icon(
                    onPressed: () => context.go('/kitchens'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.search),
                    label: const Text(
                      'ابحث عن مطبخ',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                  // For Advertisers
                  OutlinedButton.icon(
                    onPressed: () => context.go('/auth/register'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    icon: const Icon(Icons.business),
                    label: const Text(
                      'سجّل شركتك',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
