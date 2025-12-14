import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Spec 2.8: صفحة المفضلة (Favorites Page)
/// عرض الإعلانات المحفوظة مع إمكانية الإزالة والتواصل المباشر
class FavoritesPageV2 extends StatefulWidget {
  const FavoritesPageV2({super.key});

  @override
  State<FavoritesPageV2> createState() => _FavoritesPageV2State();
}

class _FavoritesPageV2State extends State<FavoritesPageV2> {
  // Mock favorites data
  final List<Map<String, dynamic>> _favorites = [
    {
      'id': '1',
      'title': 'مطبخ إيطالي فاخر',
      'company': 'مطابخ الفخامة',
      'city': 'الرياض',
      'price': 45000,
      'image': 'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=400',
      'rating': 4.8,
      'reviewsCount': 127,
      'phone': '0501234567',
      'area': 15,
      'type': 'ايطالي',
      'savedDate': '2024-12-01',
    },
    {
      'id': '2',
      'title': 'مطبخ عصري مودرن',
      'company': 'المطابخ العصرية',
      'city': 'جدة',
      'price': 38000,
      'image': 'https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?w=400',
      'rating': 4.6,
      'reviewsCount': 89,
      'phone': '0507654321',
      'area': 12,
      'type': 'مودرن',
      'savedDate': '2024-11-28',
    },
    {
      'id': '3',
      'title': 'مطبخ كلاسيكي أنيق',
      'company': 'مطابخ الأناقة',
      'city': 'الدمام',
      'price': 52000,
      'image': 'https://images.unsplash.com/photo-1556909212-d5b604d0c90d?w=400',
      'rating': 4.9,
      'reviewsCount': 156,
      'phone': '0509876543',
      'area': 18,
      'type': 'كلاسيكي',
      'savedDate': '2024-11-25',
    },
    {
      'id': '4',
      'title': 'مطبخ أمريكي واسع',
      'company': 'مطابخ الابتكار',
      'city': 'الرياض',
      'price': 48000,
      'image': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400',
      'rating': 4.7,
      'reviewsCount': 98,
      'phone': '0502345678',
      'area': 20,
      'type': 'امريكي',
      'savedDate': '2024-11-20',
    },
    {
      'id': '5',
      'title': 'مطبخ خشبي طبيعي',
      'company': 'مطابخ الطبيعة',
      'city': 'مكة المكرمة',
      'price': 41000,
      'image': 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=400',
      'rating': 4.5,
      'reviewsCount': 72,
      'phone': '0503456789',
      'area': 14,
      'type': 'خشبي',
      'savedDate': '2024-11-15',
    },
    {
      'id': '6',
      'title': 'مطبخ مينيمال بسيط',
      'company': 'مطابخ البساطة',
      'city': 'الطائف',
      'price': 35000,
      'image': 'https://images.unsplash.com/photo-1556909114-4e5682ecbaea?w=400',
      'rating': 4.4,
      'reviewsCount': 61,
      'phone': '0504567890',
      'area': 10,
      'type': 'مينيمال',
      'savedDate': '2024-11-10',
    },
  ];

  String _sortBy = 'recent'; // recent, price_low, price_high, rating

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 1000;

    // Sort favorites
    _sortFavorites();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('الإعلانات المحفوظة'),
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
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearAllDialog(context),
              tooltip: 'حذف الكل',
            ),
        ],
      ),
      body: _favorites.isEmpty
          ? _buildEmptyState(context, theme)
          : Column(
              children: [
                // Header with count and sort
                _buildHeader(theme, isWide),
                // Grid of favorites
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: Padding(
                          padding: EdgeInsets.all(isWide ? 24 : 16),
                          child: _buildFavoritesGrid(isWide),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isWide) {
    return Container(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      color: Colors.white,
      child: Row(
        children: [
          // Count
          Expanded(
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.red[400], size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_favorites.length} إعلان محفوظ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Sort dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _sortBy,
              underline: const SizedBox(),
              icon: const Icon(Icons.sort, size: 18),
              isDense: true,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
              items: const [
                DropdownMenuItem(value: 'recent', child: Text('الأحدث')),
                DropdownMenuItem(value: 'price_low', child: Text('السعر: من الأقل')),
                DropdownMenuItem(value: 'price_high', child: Text('السعر: من الأعلى')),
                DropdownMenuItem(value: 'rating', child: Text('التقييم')),
              ],
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid(bool isWide) {
    final crossAxisCount = isWide ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        return _buildFavoriteCard(context, _favorites[index], index);
      },
    );
  }

  Widget _buildFavoriteCard(BuildContext context, Map<String, dynamic> item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with favorite button
          Stack(
            children: [
              // Image
              GestureDetector(
                onTap: () => context.push('/kitchens/${item['id']}'),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: Image.network(
                      item['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.kitchen, size: 50),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Remove from favorites button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _removeFromFavorites(index),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Type badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['type'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  GestureDetector(
                    onTap: () => context.push('/kitchens/${item['id']}'),
                    child: Text(
                      item['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Company
                  Row(
                    children: [
                      Icon(Icons.business, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item['company'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // City & Area
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        item['city'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.square_foot, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${item['area']} م²',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        item['rating'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${item['reviewsCount']})',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    '${item['price'].toStringAsFixed(0)} ريال',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),

                  // Action Buttons
                  Row(
                    children: [
                      // Contact button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _contactAdvertiser(context, item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text(
                            'تواصل',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // WhatsApp button
                      ElevatedButton(
                        onPressed: () => _openWhatsApp(item['phone']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          minimumSize: const Size(44, 44),
                        ),
                        child: const Icon(Icons.chat, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد إعلانات محفوظة',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ابدأ بحفظ الإعلانات المفضلة لديك\nلتتمكن من الوصول إليها بسهولة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/kitchens'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.search),
              label: const Text('تصفح المطابخ'),
            ),
          ],
        ),
      ),
    );
  }

  void _sortFavorites() {
    switch (_sortBy) {
      case 'recent':
        _favorites.sort((a, b) => b['savedDate'].compareTo(a['savedDate']));
        break;
      case 'price_low':
        _favorites.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'price_high':
        _favorites.sort((a, b) => b['price'].compareTo(a['price']));
        break;
      case 'rating':
        _favorites.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
    }
  }

  void _removeFromFavorites(int index) {
    final item = _favorites[index];

    setState(() {
      _favorites.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إزالة "${item['title']}" من المفضلة'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'تراجع',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _favorites.insert(index, item);
            });
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف جميع المفضلات'),
        content: const Text(
          'هل أنت متأكد من حذف جميع الإعلانات المحفوظة؟',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _favorites.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف جميع المفضلات'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
  }

  void _contactAdvertiser(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'تواصل مع المعلن',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                item['title'],
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Contact options
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.phone, color: Colors.blue),
                ),
                title: const Text('اتصال هاتفي'),
                subtitle: Text(item['phone']),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _makePhoneCall(item['phone']);
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chat, color: Color(0xFF25D366)),
                ),
                title: const Text('واتساب'),
                subtitle: const Text('إرسال رسالة عبر واتساب'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _openWhatsApp(item['phone']);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن إجراء المكالمة')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    // Remove leading zero if present
    final cleanPhone = phone.startsWith('0') ? phone.substring(1) : phone;
    final uri = Uri.parse('https://wa.me/966$cleanPhone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح واتساب')),
        );
      }
    }
  }
}
