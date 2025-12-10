import 'package:flutter/material.dart';

import '../../../shared/widgets/shared_widgets.dart';
import '../../listings/presentation/widgets/kitchen_card.dart';

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
      'imageUrl': 'https://images.unsplash.com/photo-1565538810643-b5bdb714032a?w=800&h=600&fit=crop',
    },
    {
      'id': '5',
      'title': 'مطبخ أبيض فاخر',
      'city': 'مكة',
      'price': 41000.0,
      'type': 'تفصيل',
      'aiScore': 8.9,
      'imageUrl': 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&h=600&fit=crop',
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
      'imageUrl': 'https://images.unsplash.com/photo-1588854337221-4cf9fa96c527?w=800&h=600&fit=crop',
    },
    {
      'id': '8',
      'title': 'مطبخ رخام فخم',
      'city': 'الرياض',
      'price': 58000.0,
      'type': 'جاهز',
      'aiScore': 9.3,
      'imageUrl': 'https://images.unsplash.com/photo-1600489000022-c2086d79f9d4?w=800&h=600&fit=crop',
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

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Hero Section with Gradient
            Container(
              height: 320,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF2962FF),
                    Color(0xFF1976D2),
                    Color(0xFF0D47A1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2962FF).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'اكتشف مطبخ أحلامك',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'مئات التصاميم الحديثة بانتظارك',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 32),
                      // Search Box
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
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
                              fontSize: 16,
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(8),
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
                                icon: const Icon(Icons.search, color: Colors.white),
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
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          onSubmitted: (_) => _performSearch(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Quick Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppSectionHeader(
                title: 'الفئات',
                onViewAll: () {
                  Navigator.pushNamed(context, '/listings');
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final icons = [Icons.kitchen, Icons.design_services];
                  final gradients = [
                    [const Color(0xFF2962FF), const Color(0xFF1976D2)],
                    [const Color(0xFFFFC857), const Color(0xFFFFB142)],
                  ];

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/listings',
                        arguments: {'category': categories[index]},
                      );
                    },
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradients[index],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: gradients[index][0].withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              icons[index],
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
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
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // AI Recommendation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/ai-wizard'),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFF6A1B9A),
                        Color(0xFF8E24AA),
                        Color(0xFFAB47BC),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8E24AA).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'جديد',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'مساعد الذكاء الاصطناعي',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'اكتشف مطبخك المثالي في 60 ثانية',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
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
                                    color: Color(0xFF8E24AA),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'ابدأ الآن',
                                    style: TextStyle(
                                      color: Color(0xFF8E24AA),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.psychology_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Featured Kitchens
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppSectionHeader(
                title: 'مميز لك',
                onViewAll: () {
                  Navigator.pushNamed(context, '/listings');
                },
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: featuredKitchens.length,
                itemBuilder: (context, index) {
                  final kitchen = featuredKitchens[index];
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
            ),
            const SizedBox(height: 32),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
      floatingActionButton: const ChatFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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
