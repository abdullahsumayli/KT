import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/data/models/kitchen_ad.dart';
import '../../shared/data/repositories/kitchen_ads_repository.dart';

/// صفحة تفاصيل المطبخ
class ProductDetailScreen extends StatefulWidget {
  final String id;
  final String title;
  final String city;
  final double price;
  final String type;
  final double aiScore;
  final String? imageUrl;

  const ProductDetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.city,
    required this.price,
    required this.type,
    required this.aiScore,
    this.imageUrl,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final KitchenAdsRepository _repository = MockKitchenAdsRepository();
  late Future<KitchenAd?> _adFuture;
  late Future<List<KitchenAd>> _similarAdsFuture;
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _adFuture = _repository.getById(widget.id);
    _similarAdsFuture = _repository.getAll();
    _incrementViews();
  }

  Future<void> _incrementViews() async {
    try {
      await _repository.incrementViews(widget.id);
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      await _repository.incrementContactClicks(widget.id);
    }
  }

  Future<void> _sendWhatsApp(String phone, String message) async {
    final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      await _repository.incrementContactClicks(widget.id);
    }
  }

  Future<void> _shareAd(KitchenAd ad) async {
    // TODO: Implement share functionality with share_plus package
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة خاصية المشاركة قريباً')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<KitchenAd?>(
      future: _adFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text('حدث خطأ في تحميل التفاصيل'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('العودة'),
                  ),
                ],
              ),
            ),
          );
        }

        final ad = snapshot.data!;
        return _buildContent(ad);
      },
    );
  }

  Widget _buildContent(KitchenAd ad) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // صور المطبخ
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isFavorite ? 'تمت الإضافة للمفضلة' : 'تمت الإزالة من المفضلة'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareAd(ad),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ad.galleryImages.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          itemCount: ad.galleryImages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: ad.galleryImages[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.kitchen, size: 64),
                              ),
                            );
                          },
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                        // Page indicator
                        if (ad.galleryImages.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                ad.galleryImages.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Featured badge
                        if (ad.isFeatured)
                          Positioned(
                            top: 60,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber[700],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'مميز',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.kitchen, size: 64),
                    ),
            ),
          ),

          // محتوى التفاصيل
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // العنوان والسعر
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ad.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: ad.status == KitchenAdStatus.active
                                  ? Colors.green[50]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              ad.status == KitchenAdStatus.active ? 'متاح' : 'غير متاح',
                              style: TextStyle(
                                color: ad.status == KitchenAdStatus.active
                                    ? Colors.green[700]
                                    : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            ad.city,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.visibility, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${ad.viewCount} مشاهدة',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            '${ad.priceFrom.toStringAsFixed(0)} - ${ad.priceTo.toStringAsFixed(0)} ريال',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // معلومات المعلن
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(
                              ad.advertiserName[0],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ad.advertiserName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (ad.rating != null)
                                  Row(
                                    children: [
                                      Icon(Icons.star, size: 16, color: Colors.amber[700]),
                                      const SizedBox(width: 4),
                                      Text(
                                        ad.rating!.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // الوصف
                if (ad.description.isNotEmpty) ...[
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الوصف',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          ad.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // المواصفات
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'المواصفات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSpecRow('النوع', _getKitchenTypeLabel(ad.kitchenType)),
                      if (ad.material != null && ad.material!.isNotEmpty)
                        _buildSpecRow('المادة', ad.material!),
                      if (ad.area != null && ad.area!.isNotEmpty)
                        _buildSpecRow('المساحة', ad.area!),
                      if (ad.completionDays != null)
                        _buildSpecRow('مدة التنفيذ', '${ad.completionDays} يوم'),
                      if (ad.warrantyYears != null)
                        _buildSpecRow('الضمان', '${ad.warrantyYears} سنة'),
                      if (ad.has3DDesign) _buildSpecRow('تصميم ثلاثي الأبعاد', 'متوفر'),
                      if (ad.hasInstallation) _buildSpecRow('التركيب', 'متوفر'),
                      if (ad.hasShipping) _buildSpecRow('الشحن', 'متوفر'),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // المنتجات المشابهة
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'مطابخ مشابهة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<KitchenAd>>(
                        future: _similarAdsFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final similarAds =
                              snapshot.data!.where((ad) => ad.id != widget.id).take(3).toList();

                          if (similarAds.isEmpty) {
                            return const Text('لا توجد مطابخ مشابهة');
                          }

                          return SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: similarAds.length,
                              itemBuilder: (context, index) {
                                final ad = similarAds[index];
                                return _buildSimilarProductCard(ad);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _makePhoneCall('0500000000'),
                icon: const Icon(Icons.phone),
                label: const Text('اتصال'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _sendWhatsApp(
                  '966500000000',
                  'مرحباً، أنا مهتم بـ ${ad.title}',
                ),
                icon: const Icon(Icons.chat),
                label: const Text('واتساب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getKitchenTypeLabel(KitchenType type) {
    switch (type) {
      case KitchenType.modern:
        return 'مطبخ حديث';
      case KitchenType.classic:
        return 'مطبخ كلاسيكي';
      case KitchenType.neoClassic:
        return 'مطبخ نيو كلاسيك';
      case KitchenType.open:
        return 'مطبخ مفتوح';
      case KitchenType.closed:
        return 'مطبخ مغلق';
      case KitchenType.economic:
        return 'مطبخ اقتصادي';
      case KitchenType.luxury:
        return 'مطبخ فاخر';
      case KitchenType.apartment:
        return 'مطبخ شقة';
      case KitchenType.villa:
        return 'مطبخ فيلا';
    }
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProductCard(KitchenAd ad) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(
                id: ad.id,
                title: ad.title,
                city: ad.city,
                price: ad.priceFrom,
                type: _getKitchenTypeLabel(ad.kitchenType),
                aiScore: ad.rating ?? 0,
                imageUrl: ad.mainImage,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ad.mainImage != null
                    ? CachedNetworkImage(
                        imageUrl: ad.mainImage!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.kitchen),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.kitchen, size: 32),
                      ),
              ),
            ),
            // تفاصيل
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 2),
                      Text(
                        ad.city,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${ad.priceFrom.toStringAsFixed(0)} ريال',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
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
}
