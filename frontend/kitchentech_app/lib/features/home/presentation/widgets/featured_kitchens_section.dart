import 'package:flutter/material.dart';

import '../../../../shared/widgets/kitchen_ad_card.dart';
import '../../../shared/data/models/kitchen_ad.dart';

class FeaturedKitchensSection extends StatefulWidget {
  final List<KitchenAd> kitchenAds;
  final VoidCallback onViewAll;

  const FeaturedKitchensSection({
    super.key,
    required this.kitchenAds,
    required this.onViewAll,
  });

  @override
  State<FeaturedKitchensSection> createState() => _FeaturedKitchensSectionState();
}

class _FeaturedKitchensSectionState extends State<FeaturedKitchensSection> {
  String? selectedFilter;

  final List<String> filters = [
    'مودرن',
    'كلاسيك',
    'رمادي',
    'أبيض',
    'خشبي',
  ];

  List<KitchenAd> get filteredKitchens {
    if (selectedFilter == null) {
      return widget.kitchenAds;
    }
    // Filter based on kitchenType - match string to enum
    return widget.kitchenAds.where((ad) {
      final kitchenTypeLabel = _getKitchenTypeLabel(ad.kitchenType);
      return kitchenTypeLabel.contains(selectedFilter!) ||
          ad.kitchenType.name.toLowerCase() == selectedFilter!.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.onViewAll,
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'مميز لك — حسب ذوقك',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Filters Row
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = selectedFilter == filter;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFilter = isSelected ? null : filter;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Products Grid
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
            itemCount: filteredKitchens.length,
            itemBuilder: (context, index) {
              final ad = filteredKitchens[index];
              return KitchenAdCard(
                ad: ad,
                isFavorite: false, // TODO: Implement favorites logic
                onFavoriteToggle: () {
                  // TODO: Implement favorites toggle
                },
              );
            },
          ),
        ),
      ],
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
}
