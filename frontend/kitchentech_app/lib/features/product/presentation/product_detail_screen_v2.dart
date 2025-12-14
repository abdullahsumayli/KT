import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/data/models/kitchen_ad.dart';
import '../../shared/data/repositories/kitchen_ads_repository.dart';

/// صفحة تفاصيل إعلان المطبخ - Spec 2.3
class ProductDetailScreenV2 extends StatefulWidget {
  final String id;

  const ProductDetailScreenV2({
    super.key,
    required this.id,
  });

  @override
  State<ProductDetailScreenV2> createState() => _ProductDetailScreenV2State();
}

class _ProductDetailScreenV2State extends State<ProductDetailScreenV2> {
  final KitchenAdsRepository _repository = MockKitchenAdsRepository();
  late Future<KitchenAd?> _adFuture;
  late Future<List<KitchenAd>> _similarAdsFuture;
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _showQuoteForm = false;

  // نموذج طلب عرض سعر
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _adFuture = _repository.getById(widget.id);
    _similarAdsFuture = _repository.getAll();
    _incrementViews();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _incrementViews() async {
    try {
      await _repository.incrementViews(widget.id);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      await _repository.incrementContactClicks(widget.id);
    }
  }

  Future<void> _sendWhatsApp(KitchenAd ad, String phone) async {
    final message = 'مرحباً، أنا مهتم بـ ${ad.title}';
    final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      await _repository.incrementContactClicks(widget.id);
    }
  }

  Future<void> _shareAd(KitchenAd ad) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة خاصية المشاركة قريباً')),
    );
  }

  void _submitQuoteRequest() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال طلبك بنجاح! سيتم التواصل معك قريباً'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _showQuoteForm = false;
      });
      _formKey.currentState!.reset();
    }
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
            appBar: AppBar(title: const Text('خطأ')),
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
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1000;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text(
            'تفاصيل الإعلان',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
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
              icon: const Icon(Icons.share),
              onPressed: () => _shareAd(ad),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb
              _buildBreadcrumb(ad),

              // المحتوى الرئيسي
              if (isWide) _buildWideLayout(ad) else _buildNarrowLayout(ad),

              const SizedBox(height: 24),

              // المطابخ المشابهة
              _buildSimilarKitchens(),

              const SizedBox(height: 24),

              // عن المعلن
              _buildAboutAdvertiser(ad),

              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(ad),
      ),
    );
  }

  Widget _buildBreadcrumb(KitchenAd ad) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/'),
            child: Text(
              'الرئيسية',
              style: TextStyle(color: Colors.blue.shade700),
            ),
          ),
          Text(' > ', style: TextStyle(color: Colors.grey.shade600)),
          InkWell(
            onTap: () => context.go('/kitchens'),
            child: Text(
              _getKitchenTypeLabel(ad.kitchenType),
              style: TextStyle(color: Colors.blue.shade700),
            ),
          ),
          Text(' > ', style: TextStyle(color: Colors.grey.shade600)),
          Expanded(
            child: Text(
              ad.title,
              style: TextStyle(color: Colors.grey.shade800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(KitchenAd ad) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصور (الجهة اليسرى)
          Expanded(
            flex: 6,
            child: _buildImageGallery(ad),
          ),
          const SizedBox(width: 24),
          // المعلومات الأساسية (الجهة اليمنى)
          Expanded(
            flex: 4,
            child: Column(
              children: [
                _buildBasicInfo(ad),
                const SizedBox(height: 16),
                _buildSpecifications(ad),
                const SizedBox(height: 16),
                _buildDescription(ad),
                if (_showQuoteForm) ...[
                  const SizedBox(height: 16),
                  _buildQuoteForm(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(KitchenAd ad) {
    return Column(
      children: [
        _buildImageGallery(ad),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildBasicInfo(ad),
              const SizedBox(height: 16),
              _buildSpecifications(ad),
              const SizedBox(height: 16),
              _buildDescription(ad),
              if (_showQuoteForm) ...[
                const SizedBox(height: 16),
                _buildQuoteForm(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(KitchenAd ad) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // الصورة الرئيسية
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: ad.galleryImages.isNotEmpty
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
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.kitchen, size: 64),
                              ),
                            );
                          },
                        ),
                        // شارة مميز
                        if (ad.isFeatured)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC857),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Colors.black87, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'مميز',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // مؤشر الصفحات
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
                                  width: _currentImageIndex == index ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: _currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
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
          // صور مصغرة
          if (ad.galleryImages.length > 1)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ad.galleryImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _currentImageIndex == index
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            width: _currentImageIndex == index ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: CachedNetworkImage(
                            imageUrl: ad.galleryImages[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.kitchen, size: 24),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(KitchenAd ad) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Text(
            ad.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // الشركة والتقييم
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  ad.advertiserName[0],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.advertiserName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (ad.rating != null)
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            return Icon(
                              i < (ad.rating ?? 0).floor() ? Icons.star : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            '${ad.rating!.toStringAsFixed(1)} من 5',
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
            ],
          ),
          const SizedBox(height: 16),

          // المدينة/الحي
          Row(
            children: [
              Icon(Icons.location_on, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                ad.city,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.visibility, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                '${ad.viewCount} مشاهدة',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // السعر
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نطاق السعر',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ad.priceFrom.toStringAsFixed(0)} - ${ad.priceTo.toStringAsFixed(0)} ريال',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // الشارات
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (ad.hasShipping) _buildBadge('شحن وتركيب', Icons.local_shipping, Colors.green),
              if (ad.warrantyYears != null && ad.warrantyYears! > 0)
                _buildBadge('ضمان ${ad.warrantyYears} سنوات', Icons.verified_user, Colors.blue),
              if (ad.has3DDesign)
                _buildBadge('تصميم ثلاثي الأبعاد', Icons.view_in_ar, Colors.purple),
              if (ad.hasInstallation) _buildBadge('تركيب', Icons.construction, Colors.orange),
              if (ad.completionDays != null && ad.completionDays! <= 30)
                _buildBadge('جاهز خلال ${ad.completionDays} يوم', Icons.schedule, Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications(KitchenAd ad) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مواصفات تفصيلية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSpecRow('نوع المطبخ', _getKitchenTypeLabel(ad.kitchenType)),
          if (ad.material != null && ad.material!.isNotEmpty)
            _buildSpecRow('المواد المستخدمة', ad.material!),
          if (ad.area != null && ad.area!.isNotEmpty) _buildSpecRow('المساحة', ad.area!),
          if (ad.completionDays != null)
            _buildSpecRow('مدة التنفيذ المتوقعة', '${ad.completionDays} يوم'),
          _buildSpecRow('شروط الدفع', 'دفعة مقدمة 50% + دفعة عند التسليم 50%'),
          if (ad.hasInstallation || ad.has3DDesign)
            _buildSpecRow(
              'الخدمات الإضافية',
              [
                if (ad.has3DDesign) 'تصميم ثلاثي الأبعاد',
                if (ad.hasInstallation) 'تركيب',
                'استشارة مجانية',
              ].join(' • '),
            ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(KitchenAd ad) {
    if (ad.description.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'وصف تفصيلي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ad.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'طلب معاينة / عرض سعر',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _showQuoteForm = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'رقم الجوال *',
                border: OutlineInputBorder(),
                prefixText: '+966 ',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الجوال';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'المدينة *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال المدينة';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(
                labelText: 'مساحة المطبخ التقريبية (متر مربع)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'رسالة',
                border: OutlineInputBorder(),
                hintText: 'أضف أي تفاصيل إضافية...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitQuoteRequest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('إرسال الطلب'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarKitchens() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مطابخ مشابهة',
            style: TextStyle(
              fontSize: 20,
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

              final similarAds = snapshot.data!.where((ad) => ad.id != widget.id).take(4).toList();

              if (similarAds.isEmpty) {
                return const Text('لا توجد مطابخ مشابهة');
              }

              return SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: similarAds.length,
                  itemBuilder: (context, index) {
                    final ad = similarAds[index];
                    return _buildSimilarCard(ad);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarCard(KitchenAd ad) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(left: 16),
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
      child: InkWell(
        onTap: () {
          context.go('/kitchens/${ad.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 10,
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
                          child: const Icon(Icons.kitchen, size: 32),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.kitchen, size: 32),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        ad.city,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${ad.priceFrom.toStringAsFixed(0)} - ${ad.priceTo.toStringAsFixed(0)} ريال',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  if (ad.rating != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(
                          ad.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildAboutAdvertiser(KitchenAd ad) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'عن المعلن',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  ad.advertiserName[0],
                  style: const TextStyle(
                    fontSize: 32,
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'شركة متخصصة في تصميم وتصنيع المطابخ العصرية',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.storefront,
                  label: 'عدد الإعلانات',
                  value: '12 إعلان',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.star,
                  label: 'متوسط التقييمات',
                  value: ad.rating != null ? '${ad.rating!.toStringAsFixed(1)} من 5' : 'لا يوجد',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoTile(
            icon: Icons.location_on,
            label: 'موقع المعرض',
            value: '${ad.city} - شارع الملك فهد',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(KitchenAd ad) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showQuoteForm = !_showQuoteForm;
                });
              },
              icon: const Icon(Icons.edit_note),
              label: const Text('طلب عرض سعر'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _sendWhatsApp(ad, '966500000000'),
              icon: const Icon(Icons.chat),
              label: const Text('واتساب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _makePhoneCall('0500000000'),
              icon: const Icon(Icons.phone),
              label: const Text('اتصال'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
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
        return 'منفصل';
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
