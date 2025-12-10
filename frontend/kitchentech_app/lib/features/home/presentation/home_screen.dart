import 'package:flutter/material.dart';

import '../../../shared/widgets/shared_widgets.dart';
import 'widgets/ai_assistant_card.dart';
import 'widgets/discount_offer_card.dart';
import 'widgets/featured_kitchens_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> categories = ['جاهز', 'تفصيل'];

  // Mock data - replace with real API call
  final List<Map<String, dynamic>> featuredKitchens = [
    {
      'id': '1',
      'title': 'مطبخ حديث مع جزيرة',
      'city': 'الرياض',
      'price': 45000.0,
      'type': 'جاهز',
      'aiScore': 9.2,
      'imageUrl': 'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=800&h=600&fit=crop',
    },
    {
      'id': '2',
      'title': 'مطبخ عصري تفصيل',
      'city': 'جدة',
      'price': 35000.0,
      'type': 'تفصيل',
      'aiScore': 8.7,
      'imageUrl': 'https://images.unsplash.com/photo-1556909172-54557c7e4fb7?w=800&h=600&fit=crop',
    },
    {
      'id': '3',
      'title': 'مطبخ خشبي كلاسيكي',
      'city': 'الدمام',
      'price': 38000.0,
      'type': 'جاهز',
      'aiScore': 8.5,
      'imageUrl': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=600&fit=crop',
    },
    {
      'id': '4',
      'title': 'مطبخ مودرن متكامل',
      'city': 'الرياض',
      'price': 52000.0,
      'type': 'جاهز',
      'aiScore': 9.5,
      'imageUrl':
          'https://images.unsplash.com/photo-1565538810643-b5bdb714032a?w=800&h=600&fit=crop',
    },
    {
      'id': '5',
      'title': 'مطبخ أبيض فاخر',
      'city': 'مكة',
      'price': 41000.0,
      'type': 'تفصيل',
      'aiScore': 8.9,
      'imageUrl':
          'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&h=600&fit=crop',
    },
    {
      'id': '6',
      'title': 'مطبخ رمادي أنيق',
      'city': 'جدة',
      'price': 39000.0,
      'type': 'جاهز',
      'aiScore': 8.4,
      'imageUrl': 'https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?w=800&h=600&fit=crop',
    },
    {
      'id': '7',
      'title': 'مطبخ عصري بإضاءة LED',
      'city': 'الخبر',
      'price': 47000.0,
      'type': 'تفصيل',
      'aiScore': 9.1,
      'imageUrl':
          'https://images.unsplash.com/photo-1588854337221-4cf9fa96c527?w=800&h=600&fit=crop',
    },
    {
      'id': '8',
      'title': 'مطبخ رخام فخم',
      'city': 'الرياض',
      'price': 58000.0,
      'type': 'جاهز',
      'aiScore': 9.3,
      'imageUrl':
          'https://images.unsplash.com/photo-1600489000022-c2086d79f9d4?w=800&h=600&fit=crop',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    Navigator.pushNamed(
      context,
      '/listings',
      arguments: {'searchQuery': _searchController.text},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'KitchenTech',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/logo.png',
                height: 32,
                fit: BoxFit.contain,
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {},
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 16),

                // 1. Search Hero
                _buildSearchSection(theme),
                const SizedBox(height: 24),

                // 2. Categories Row (جاهز / تفصيل)
                _buildCategoriesRow(),
                const SizedBox(height: 24),

                // 3. Discount Offer Card
                const DiscountOfferCard(),
                const SizedBox(height: 16),

                // 4. AI Assistant Card
                AIAssistantCard(
                  onTap: () => Navigator.pushNamed(context, '/ai-wizard'),
                ),
                const SizedBox(height: 16),

                // 5. "مميز لك — حسب ذوقك" Section + Filters + Products Grid
                FeaturedKitchensSection(
                  kitchens: featuredKitchens,
                  onViewAll: () {
                    Navigator.pushNamed(context, '/listings');
                  },
                ),
                const SizedBox(height: 32),

                // 6. Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
        floatingActionButton: const ChatFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  Widget _buildAdBanner1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFC857),
              Color(0xFFFFB142),
              Color(0xFFFF9800),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFC857).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: -20,
              bottom: -20,
              child: Icon(
                Icons.kitchen,
                size: 150,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'عرض خاص',
                            style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'خصم حتى 40%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'على جميع المطابخ الجاهزة',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                color: Color(0xFFFF9800),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'استكشف الآن',
                                style: TextStyle(
                                  color: Color(0xFFFF9800),
                                  fontWeight: FontWeight.bold,
                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAdBanner2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: const Color(0xFF2962FF).withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2962FF),
                    Color(0xFF1976D2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.build_circle,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'خدمة الترك يب والصيانة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'فريق محترف متاح 24/7',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2962FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'اتصل بنا',
                          style: TextStyle(
                            color: Color(0xFF2962FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdBanner3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1A237E),
              Color(0xFF283593),
              Color(0xFF3949AB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF283593).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'شركاؤنا الموثوقون',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBrandLogo('ألمنيوم'),
                _buildBrandLogo('خشب'),
                _buildBrandLogo('رخام'),
                _buildBrandLogo('زجاج'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'أكثر من 500 مطبخ بأعلى جودة',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandLogo(String name) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'ابحث عن مطبخك المثالي...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 15,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2962FF),
                  Color(0xFF1976D2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 20),
              onPressed: _performSearch,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }

  Widget _buildCategoriesRow() {
    final icons = [Icons.kitchen, Icons.design_services];
    final gradients = [
      [const Color(0xFF2962FF), const Color(0xFF1976D2)],
      [const Color(0xFFFFC857), const Color(0xFFFFB142)],
    ];

    return Row(
      children: List.generate(categories.length, (index) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/listings',
                arguments: {'category': categories[index]},
              );
            },
            child: Container(
              margin: EdgeInsets.only(
                right: index == 0 ? 0 : 6,
                left: index == categories.length - 1 ? 0 : 6,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradients[index],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradients[index][0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icons[index],
                    size: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    categories[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A237E),
            Color(0xFF0D47A1),
            Color(0xFF01579B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Logo and Description
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'KitchenTech',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'منصتك الذكية لبيع وشراء المطابخ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Links Section
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 40,
                  runSpacing: 24,
                  children: [
                    _buildFooterColumn(
                      'روابط سريعة',
                      [
                        'الرئيسية',
                        'تصفح المطابخ',
                        'أضف إعلان',
                        'من نحن',
                      ],
                    ),
                    _buildFooterColumn(
                      'خدماتنا',
                      [
                        'مطابخ جاهزة',
                        'مطابخ تفصيل',
                        'توصيات AI',
                        'استشارات مجانية',
                      ],
                    ),
                    _buildFooterColumn(
                      'تواصل معنا',
                      [
                        'البريد الإلكتروني',
                        'الهاتف',
                        'تويتر',
                        'انستقرام',
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Social Media Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIcon(Icons.facebook),
                    const SizedBox(width: 16),
                    _buildSocialIcon(Icons.email),
                    const SizedBox(width: 16),
                    _buildSocialIcon(Icons.phone),
                    const SizedBox(width: 16),
                    _buildSocialIcon(Icons.camera_alt),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Copyright Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '© 2025 KitchenTech. جميع الحقوق محفوظة',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              item,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
