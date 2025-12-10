import 'package:flutter/material.dart';

import '../../../listings/presentation/widgets/kitchen_card.dart';

class FeaturedKitchensSection extends StatefulWidget {
  final List<Map<String, dynamic>> kitchens;
  final VoidCallback onViewAll;

  const FeaturedKitchensSection({
    super.key,
    required this.kitchens,
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

  List<Map<String, dynamic>> get filteredKitchens {
    if (selectedFilter == null) {
      return widget.kitchens;
    }
    // For now, return all kitchens since we don't have filter metadata
    // In a real app, you would filter based on kitchen properties
    return widget.kitchens;
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
              final kitchen = filteredKitchens[index];
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
      ],
    );
  }
}
