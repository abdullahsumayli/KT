import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_constants.dart';
import '../../../shared/widgets/kitchen_ad_card.dart';
import '../../shared/data/models/kitchen_ad.dart';
import '../../shared/data/repositories/kitchen_ads_repository.dart';

/// شاشة عرض قائمة المطابخ مع الفلاتر المتقدمة
class ListingsScreen extends StatefulWidget {
  final String? searchQuery;
  final String? category;
  final String? city;
  final String? priceRange;

  const ListingsScreen({
    super.key,
    this.searchQuery,
    this.category,
    this.city,
    this.priceRange,
  });

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  final KitchenAdsRepository _repository = MockKitchenAdsRepository();
  late Future<List<KitchenAd>> _adsFuture;

  // Filters
  String? _selectedCategory;
  String? _selectedCity;
  String? _selectedPriceRange;
  String? _searchQuery;
  String _sortBy = 'recent'; // recent, price_low, price_high, rating

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize from widget params
    _selectedCategory = widget.category;
    _selectedCity = widget.city;
    _selectedPriceRange = widget.priceRange;
    _searchQuery = widget.searchQuery;

    if (_searchQuery != null) {
      _searchController.text = _searchQuery!;
    }

    _loadAds();
  }

  void _loadAds() {
    setState(() {
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        _adsFuture = _repository.search(query: _searchQuery!);
      } else {
        _adsFuture = _repository.getAll();
      }
    });
  }

  List<KitchenAd> _applyFilters(List<KitchenAd> ads) {
    var filtered = ads;

    // Filter by category
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      // Try to match the string to a KitchenType enum value
      try {
        final kitchenType = KitchenType.values.firstWhere(
          (type) =>
              type.name.toLowerCase() == _selectedCategory!.toLowerCase() ||
              _getKitchenTypeLabel(type) == _selectedCategory,
        );
        filtered = filtered.where((ad) => ad.kitchenType == kitchenType).toList();
      } catch (e) {
        // If no match found, don't filter
      }
    }

    // Filter by city
    if (_selectedCity != null && _selectedCity!.isNotEmpty) {
      filtered = filtered.where((ad) => ad.city == _selectedCity).toList();
    }

    // Filter by price range
    if (_selectedPriceRange != null && _selectedPriceRange!.isNotEmpty) {
      final parts = _selectedPriceRange!.split('-');
      if (parts.length == 2) {
        final min = double.tryParse(parts[0]) ?? 0;
        final max = double.tryParse(parts[1]) ?? double.infinity;
        filtered = filtered.where((ad) {
          final price = ad.priceFrom;
          return price >= min && price <= max;
        }).toList();
      }
    }

    // Sort
    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.priceFrom.compareTo(b.priceFrom));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.priceFrom.compareTo(a.priceFrom));
        break;
      case 'rating':
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case 'recent':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
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

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FiltersBottomSheet(
        selectedCategory: _selectedCategory,
        selectedCity: _selectedCity,
        selectedPriceRange: _selectedPriceRange,
        onApply: (category, city, priceRange) {
          setState(() {
            _selectedCategory = category;
            _selectedCity = city;
            _selectedPriceRange = priceRange;
          });
        },
        onReset: () {
          setState(() {
            _selectedCategory = null;
            _selectedCity = null;
            _selectedPriceRange = null;
          });
        },
      ),
    );
  }

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text;
      _loadAds();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('تصفح المطابخ'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2962FF), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search and Filters Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'ابحث عن مطبخك المثالي...',
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _performSearch,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = null;
                                      _loadAds();
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Filter Chips and Sort
                Row(
                  children: [
                    // Sort Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sortBy,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'recent', child: Text('الأحدث')),
                              DropdownMenuItem(value: 'price_low', child: Text('السعر: من الأقل')),
                              DropdownMenuItem(
                                  value: 'price_high', child: Text('السعر: من الأعلى')),
                              DropdownMenuItem(value: 'rating', child: Text('الأعلى تقييماً')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _sortBy = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Filters Button
                    ElevatedButton.icon(
                      onPressed: _showFiltersBottomSheet,
                      icon: const Icon(Icons.filter_list),
                      label: Text(
                        _hasActiveFilters() ? 'فلاتر (${_getActiveFiltersCount()})' : 'فلاتر',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _hasActiveFilters() ? theme.colorScheme.primary : Colors.grey[200],
                        foregroundColor: _hasActiveFilters() ? Colors.white : Colors.grey[700],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                // Active Filters Chips
                if (_hasActiveFilters()) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      if (_selectedCategory != null)
                        _buildFilterChip(_selectedCategory!, () {
                          setState(() => _selectedCategory = null);
                        }),
                      if (_selectedCity != null)
                        _buildFilterChip(_selectedCity!, () {
                          setState(() => _selectedCity = null);
                        }),
                      if (_selectedPriceRange != null)
                        _buildFilterChip(_formatPriceRange(_selectedPriceRange!), () {
                          setState(() => _selectedPriceRange = null);
                        }),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Results
          Expanded(
            child: FutureBuilder<List<KitchenAd>>(
              future: _adsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'حدث خطأ في تحميل المطابخ',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ],
                    ),
                  );
                }

                final allAds = snapshot.data ?? [];
                final filteredAds = _applyFilters(allAds);

                if (filteredAds.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'لم يتم العثور على نتائج',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'جرب تعديل الفلاتر أو البحث',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredAds.length,
                  itemBuilder: (context, index) {
                    final ad = filteredAds[index];
                    return KitchenAdCard(
                      ad: ad,
                      isFavorite: false, // TODO: Implement favorites
                      onFavoriteToggle: () {
                        // TODO: Toggle favorite
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/dashboard/new-ad'),
        icon: const Icon(Icons.add),
        label: const Text('أضف إعلان'),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategory != null || _selectedCity != null || _selectedPriceRange != null;
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_selectedCategory != null) count++;
    if (_selectedCity != null) count++;
    if (_selectedPriceRange != null) count++;
    return count;
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Chip(
      label: Text(label),
      onDeleted: onDelete,
      deleteIcon: const Icon(Icons.close, size: 16),
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatPriceRange(String range) {
    final parts = range.split('-');
    if (parts.length == 2) {
      return '${parts[0]}-${parts[1]} ر.س';
    }
    return range;
  }
}

/// Bottom Sheet للفلاتر المتقدمة
class _FiltersBottomSheet extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedCity;
  final String? selectedPriceRange;
  final Function(String?, String?, String?) onApply;
  final VoidCallback onReset;

  const _FiltersBottomSheet({
    this.selectedCategory,
    this.selectedCity,
    this.selectedPriceRange,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  String? _category;
  String? _city;
  String? _priceRange;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _city = widget.selectedCity;
    _priceRange = widget.selectedPriceRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'الفلاتر',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _category = null;
                        _city = null;
                        _priceRange = null;
                      });
                      widget.onReset();
                      Navigator.pop(context);
                    },
                    child: const Text('إعادة تعيين'),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Category Filter
              const Text(
                'الفئة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: KitchenCategories.names.map((category) {
                  final isSelected = _category == category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _category = selected ? category : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // City Filter
              const Text(
                'المدينة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: SaudiCities.major.map((city) {
                  final isSelected = _city == city;
                  return ChoiceChip(
                    label: Text(city),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _city = selected ? city : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Price Range Filter
              const Text(
                'نطاق السعر',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: BudgetRanges.all.map((range) {
                  final isSelected = _priceRange == range['value'];
                  return ChoiceChip(
                    label: Text(range['label']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _priceRange = selected ? range['value'] : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Apply Button
              ElevatedButton(
                onPressed: () {
                  widget.onApply(_category, _city, _priceRange);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'تطبيق الفلاتر',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
