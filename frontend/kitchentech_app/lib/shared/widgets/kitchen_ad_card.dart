import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/shared/data/models/kitchen_ad.dart';

/// بطاقة قابلة لإعادة الاستخدام لعرض إعلان مطبخ
class KitchenAdCard extends StatelessWidget {
  final KitchenAd ad;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const KitchenAdCard({
    super.key,
    required this.ad,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/kitchens/${ad.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المطبخ مع شارة مميز وزر المفضلة
            _buildImageSection(context),

            // معلومات المطبخ
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Text(
                    ad.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // اسم المعلن
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ad.advertiserName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // المدينة
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ad.city,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // السعر والتقييم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // السعر
                      _buildPriceWidget(theme),

                      // التقييم
                      if (ad.rating != null && ad.rating! > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              ad.rating!.toStringAsFixed(1),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // عدد المشاهدات (اختياري)
                  if (ad.viewCount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${ad.viewCount} مشاهدة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
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

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        // الصورة
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ad.galleryImages.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: ad.galleryImages.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.kitchen,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.kitchen,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
        ),

        // شارة "مميز" في الزاوية العلوية اليسرى
        if (ad.isFeatured)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber[700],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'مميز',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ),

        // زر المفضلة في الزاوية العلوية اليمنى
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey[700],
                size: 20,
              ),
              onPressed: onFavoriteToggle,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceWidget(ThemeData theme) {
    final priceFrom = ad.priceFrom;
    final priceTo = ad.priceTo;

    String priceText;
    if (priceFrom == priceTo) {
      priceText = '${_formatPrice(priceFrom)} ر.س';
    } else {
      priceText = '${_formatPrice(priceFrom)}-${_formatPrice(priceTo)} ر.س';
    }

    return Text(
      priceText,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}k';
    }
    return price.toStringAsFixed(0);
  }
}
