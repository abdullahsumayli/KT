import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // Mock favorites data
  final List<Map<String, dynamic>> _favorites = [
    {
      'id': '1',
      'title': 'مطبخ ايطالي فاخر',
      'city': 'الرياض',
      'price': 45000,
      'image': 'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=400',
      'rating': 4.8,
      'phone': '0501234567',
    },
    {
      'id': '2',
      'title': 'مطبخ عصري مودرن',
      'city': 'جدة',
      'price': 38000,
      'image': 'https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?w=400',
      'rating': 4.6,
      'phone': '0507654321',
    },
    {
      'id': '3',
      'title': 'مطبخ كلاسيكي',
      'city': 'الدمام',
      'price': 52000,
      'image': 'https://images.unsplash.com/photo-1556909212-d5b604d0c90d?w=400',
      'rating': 4.9,
      'phone': '0509876543',
    },
  ];

  void _removeFromFavorites(int index) {
    setState(() {
      final item = _favorites.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إزالة "${item['title']}" من المفضلة'),
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () {
              setState(() {
                _favorites.insert(index, item);
              });
            },
          ),
        ),
      );
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن إجراء المكالمة')),
        );
      }
    }
  }

  Future<void> _sendWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: phoneNumber.replaceAll(RegExp(r'^0'), '966'),
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح واتساب')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        centerTitle: true,
      ),
      body: _favorites.isEmpty
          ? _buildEmptyState()
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'لديك ${_favorites.length} مطبخ في المفضلة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _favorites[index];
                        return _buildFavoriteCard(item, index, colorScheme);
                      },
                      childCount: _favorites.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مطابخ في المفضلة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بتصفح المطابخ وأضف المفضلة لديك',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.go('/kitchens');
            },
            icon: const Icon(Icons.search),
            label: const Text('تصفح المطابخ'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(
    Map<String, dynamic> item,
    int index,
    ColorScheme colorScheme,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image with favorite button
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    context.go('/kitchens/${item['id']}');
                  },
                  child: CachedNetworkImage(
                    imageUrl: item['image'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton.filled(
                    onPressed: () => _removeFromFavorites(index),
                    icon: const Icon(Icons.favorite),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item['title'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['city'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating and Price
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['rating'].toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        '${item['price']} ر.س',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Contact Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () => _makePhoneCall(item['phone']),
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('اتصال'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _sendWhatsApp(item['phone']),
                          icon: const Icon(Icons.chat, size: 18),
                          label: const Text('واتساب'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
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
}
