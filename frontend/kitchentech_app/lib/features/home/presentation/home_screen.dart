import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/shared_widgets.dart';
import '../../shared/data/models/kitchen_ad.dart';
import '../../shared/data/repositories/kitchen_ads_repository.dart';

/// الشاشة الرئيسية - Home Page
/// تعرض المنصة بشكل جذاب وتدفع المستخدم للبحث أو تصفح المطابخ
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final KitchenAdsRepository _repository = MockKitchenAdsRepository();
  late Future<List<KitchenAd>> _featuredAdsFuture;

  @override
  void initState() {
    super.initState();
    _featuredAdsFuture = _repository.getFeatured();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_searchController.text.isNotEmpty) {
      context.go('/kitchens?search=${_searchController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1200;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: CustomScrollView(
          slivers: [
            // رأس الصفحة (Header شبيه بأمازون)
            _buildAppBar(theme, isWide),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  // بانر رئيسي (Hero Section)
                  _buildHeroSection(theme, isWide),

                  const SizedBox(height: 48),

                  // أقسام رئيسية (Categories)
                  _buildCategoriesSection(theme, isWide),

                  const SizedBox(height: 48),

                  // مطابخ مميزة (Featured Kitchens)
                  _buildFeaturedKitchensSection(theme, isWide),

                  const SizedBox(height: 48),

                  // شركات/ورش موصى بها
                  _buildRecommendedCompanies(theme, isWide),

                  const SizedBox(height: 64),

                  // تذييل (Footer)
                  _buildFooter(theme),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: const ChatFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  /// رأس الصفحة (Header)
  SliverAppBar _buildAppBar(ThemeData theme, bool isWide) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 1,
      toolbarHeight: 80,
      title: Row(
        children: [
          // شعار المنصة
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 50,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              const Text(
                'Kitchen Tech',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2962FF),
                ),
              ),
            ],
          ),

          const SizedBox(width: 24),

          // مربع بحث كبير في المنتصف
          if (isWide)
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: _buildSearchBar(theme),
              ),
            ),

          const Spacer(),

          // قائمة مختصرة
          if (isWide) ...[
            TextButton.icon(
              onPressed: () => context.go('/kitchens'),
              icon: const Icon(Icons.category_outlined),
              label: const Text('تصفّح الأقسام'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => context.go('/auth/login'),
              icon: const Icon(Icons.login),
              label: const Text('سجّل دخول'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => context.go('/auth/register'),
              child: const Text('إنشاء حساب'),
            ),
            const SizedBox(width: 8),
          ],

          // زر "أضف إعلانك" (للمعلنين)
          ElevatedButton.icon(
            onPressed: () => context.go('/dashboard/new-ad'),
            icon: const Icon(Icons.add_business),
            label: const Text('أضف إعلانك'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              backgroundColor: const Color(0xFFFFC857),
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  /// مربع البحث
  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textAlign: TextAlign.right,
        onSubmitted: (_) => _performSearch(),
        decoration: InputDecoration(
          hintText: 'ابحث عن المطبخ المثالي... (نوع، مدينة، سعر)',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          prefixIcon: IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.primary),
            onPressed: _performSearch,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  /// بانر رئيسي (Hero Section)
  Widget _buildHeroSection(ThemeData theme, bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 20,
        vertical: isWide ? 80 : 48,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // العنوان
          Text(
            'اكتشف أفضل تصاميم المطابخ في السعودية',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isWide ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 16),

          // النص القصير
          Text(
            'منصة تجمع شركات المطابخ، الورش، والمصممين في مكان واحد.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isWide ? 20 : 16,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 32),

          // مربع البحث (للشاشات الصغيرة)
          if (!isWide) ...[
            _buildSearchBar(theme),
            const SizedBox(height: 24),
          ],

          // زرّين
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => context.go('/kitchens'),
                icon: const Icon(Icons.search, size: 24),
                label: const Text('استعرض المطابخ', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/auth/register'),
                icon: const Icon(Icons.business, size: 24),
                label: const Text('سجّل كمورّد مطابخ', style: TextStyle(fontSize: 18)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  side: BorderSide(color: theme.colorScheme.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// أقسام رئيسية (Categories)
  Widget _buildCategoriesSection(ThemeData theme, bool isWide) {
    final categories = [
      {'name': 'مودرن', 'icon': Icons.kitchen, 'type': KitchenType.modern},
      {'name': 'كلاسيك', 'icon': Icons.chair, 'type': KitchenType.classic},
      {'name': 'مطابخ اقتصادية', 'icon': Icons.attach_money, 'type': KitchenType.economic},
      {'name': 'مطابخ فاخرة', 'icon': Icons.diamond, 'type': KitchenType.luxury},
      {'name': 'مطابخ شقق', 'icon': Icons.apartment, 'type': KitchenType.apartment},
      {'name': 'مطابخ فلل', 'icon': Icons.villa, 'type': KitchenType.villa},
      {'name': 'مطابخ مفتوحة', 'icon': Icons.open_in_full, 'type': KitchenType.open},
      {'name': 'مطابخ مغلقة', 'icon': Icons.meeting_room, 'type': KitchenType.closed},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تصفّح حسب النوع',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(
                category['name'] as String,
                category['icon'] as IconData,
                category['type'] as KitchenType,
                theme,
              );
            },
          ),
        ],
      ),
    );
  }

  /// كرت قسم واحد
  Widget _buildCategoryCard(
    String name,
    IconData icon,
    KitchenType type,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () {
        context.go('/kitchens?category=${type.name}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// مطابخ مميزة (Featured Kitchens)
  Widget _buildFeaturedKitchensSection(ThemeData theme, bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'مطابخ مميزة',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.go('/kitchens'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<KitchenAd>>(
            future: _featuredAdsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'حدث خطأ في تحميل المطابخ',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final ads = snapshot.data ?? [];

              if (ads.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Text('لا توجد مطابخ مميزة حالياً'),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 3 : 1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: isWide ? 0.75 : 1.2,
                ),
                itemCount: ads.length > 6 ? 6 : ads.length,
                itemBuilder: (context, index) {
                  return _buildKitchenCard(ads[index], theme);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// بطاقة مطبخ واحد
  Widget _buildKitchenCard(KitchenAd ad, ThemeData theme) {
    return InkWell(
      onTap: () {
        context.go('/kitchens/${ad.id}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة رئيسية
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ad.mainImage != null
                        ? Image.network(
                            ad.mainImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.kitchen, size: 48),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.kitchen, size: 48),
                          ),
                  ),
                ),
                // شارة "إعلان مميز"
                if (ad.isFeatured)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC857),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.black87),
                          SizedBox(width: 4),
                          Text(
                            'مميز',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // التفاصيل
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم الشركة / الورشة
                  Text(
                    ad.advertiserName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // عنوان الإعلان
                  Text(
                    ad.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // نوع المطبخ + المدينة
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getKitchenTypeLabel(ad.kitchenType),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ad.city,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // نطاق السعر
                  Row(
                    children: [
                      Text(
                        'من ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        ad.priceFrom.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        ' إلى ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        ad.priceTo.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        ' ريال',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  // التقييم
                  if (ad.rating != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < (ad.rating ?? 0).floor() ? Icons.star : Icons.star_border,
                            size: 16,
                            color: const Color(0xFFFFC857),
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          '${ad.rating?.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (ad.reviewCount != null && ad.reviewCount! > 0) ...[
                          Text(
                            ' (${ad.reviewCount})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// شركات/ورش موصى بها
  Widget _buildRecommendedCompanies(ThemeData theme, bool isWide) {
    // بيانات تجريبية للشركات الموصى بها
    final companies = [
      {
        'name': 'مطابخ الفخامة',
        'logo': Icons.business,
        'rating': 4.8,
        'reviews': 127,
      },
      {
        'name': 'ورشة الإبداع',
        'logo': Icons.construction,
        'rating': 4.6,
        'reviews': 89,
      },
      {
        'name': 'التصاميم المودرن',
        'logo': Icons.apartment,
        'rating': 4.9,
        'reviews': 156,
      },
      {
        'name': 'مطابخ الرياض',
        'logo': Icons.home_work,
        'rating': 4.7,
        'reviews': 98,
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 80 : 20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'شركات وورش موصى بها',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 4 : 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.3,
            ),
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index];
              return _buildCompanyCard(
                company['name'] as String,
                company['logo'] as IconData,
                company['rating'] as double,
                company['reviews'] as int,
                theme,
              );
            },
          ),
        ],
      ),
    );
  }

  /// كرت شركة واحدة
  Widget _buildCompanyCard(
    String name,
    IconData logo,
    double rating,
    int reviews,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () {
        // الانتقال لصفحة الشركة
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(logo, size: 36, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 14, color: Color(0xFFFFC857)),
                const SizedBox(width: 4),
                Text(
                  '$rating',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' ($reviews)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// تذييل (Footer)
  Widget _buildFooter(ThemeData theme) {
    final footerLinks = [
      {'title': 'من نحن', 'route': '/about'},
      {'title': 'كيف تعمل المنصّة', 'route': '/how-it-works'},
      {'title': 'الأسئلة الشائعة', 'route': '/faq'},
      {'title': 'تواصل معنا', 'route': '/contact'},
      {'title': 'الشروط والأحكام', 'route': '/terms'},
      {'title': 'سياسة الخصوصية', 'route': '/privacy'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
      ),
      child: Column(
        children: [
          // شعار المنصة
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Kitchen Tech',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // روابط
          Wrap(
            spacing: 32,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: footerLinks.map((link) {
              return InkWell(
                onTap: () {
                  context.go(link['route'] as String);
                },
                child: Text(
                  link['title'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    decoration: TextDecoration.underline,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // حقوق النشر
          Text(
            '© 2025 Kitchen Tech. جميع الحقوق محفوظة.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getKitchenTypeLabel(KitchenType type) {
    switch (type) {
      case KitchenType.modern:
        return 'مودرن';
      case KitchenType.classic:
        return 'كلاسيك';
      case KitchenType.neoClassic:
        return 'نيو كلاسيك';
      case KitchenType.open:
        return 'مفتوح';
      case KitchenType.closed:
        return 'مغلق';
      case KitchenType.economic:
        return 'اقتصادي';
      case KitchenType.luxury:
        return 'فاخر';
      case KitchenType.apartment:
        return 'شقق';
      case KitchenType.villa:
        return 'فلل';
    }
  }
}
