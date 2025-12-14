import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/data/models/kitchen_ad.dart';
import '../../shared/data/repositories/kitchen_ads_repository.dart';

/// صفحة نتائج البحث / استعراض المطابخ (Listing / Search Results)
/// عرض قائمة من إعلانات المطابخ مع فلاتر قوية تشبه أمازون
class ListingsScreenV2 extends StatefulWidget {
  final String? searchQuery;
  final String? category;
  final String? city;

  const ListingsScreenV2({
    super.key,
    this.searchQuery,
    this.category,
    this.city,
  });

  @override
  State<ListingsScreenV2> createState() => _ListingsScreenV2State();
}

class _ListingsScreenV2State extends State<ListingsScreenV2> {
  final KitchenAdsRepository _repository = MockKitchenAdsRepository();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Future<List<KitchenAd>> _adsFuture;
  List<KitchenAd> _allAds = [];
  List<KitchenAd> _filteredAds = [];
  final Set<String> _favorites = {};

  // الفلاتر
  String? _selectedCity;
  String? _selectedBudgetRange;
  KitchenType? _selectedKitchenType;
  String? _selectedMaterial;
  String? _selectedQualityLevel;
  double? _minRating;
  bool _viewAsGrid = true;
  String _sortBy = 'recent'; // recent, rating, price_low, price_high, views

  // قوائم الفلاتر
  final List<String> _cities = [
    'الكل',
    'الرياض',
    'جدة',
    'الدمام',
    'مكة',
    'المدينة',
    'الخبر',
    'تبوك',
    'أبها',
  ];

  final List<Map<String, dynamic>> _budgetRanges = [
    {'label': 'الكل', 'min': null, 'max': null},
    {'label': 'أقل من 20,000', 'min': 0.0, 'max': 20000.0},
    {'label': '20,000 - 40,000', 'min': 20000.0, 'max': 40000.0},
    {'label': '40,000 - 70,000', 'min': 40000.0, 'max': 70000.0},
    {'label': 'أكثر من 70,000', 'min': 70000.0, 'max': null},
  ];

  final List<String> _materials = [
    'الكل',
    'MDF',
    'خشب طبيعي',
    'ألمنيوم',
    'مزيج',
  ];

  final List<String> _qualityLevels = [
    'الكل',
    'اقتصادي',
    'متوسط',
    'فاخر',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery ?? '';
    _selectedCity = widget.city;

    if (widget.category != null) {
      try {
        _selectedKitchenType = KitchenType.values.firstWhere(
          (type) => type.name.toLowerCase() == widget.category!.toLowerCase(),
        );
      } catch (_) {}
    }

    _loadAds();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAds() async {
    setState(() {
      _adsFuture = _repository.getAll();
    });

    _adsFuture.then((ads) {
      setState(() {
        _allAds = ads;
        _applyFiltersAndSort();
      });
    });
  }

  void _applyFiltersAndSort() {
    var filtered = List<KitchenAd>.from(_allAds);

    // البحث النصي
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((ad) {
        return ad.title.toLowerCase().contains(query) ||
            ad.description.toLowerCase().contains(query) ||
            ad.advertiserName.toLowerCase().contains(query) ||
            ad.city.toLowerCase().contains(query);
      }).toList();
    }

    // المدينة
    if (_selectedCity != null && _selectedCity != 'الكل') {
      filtered = filtered.where((ad) => ad.city == _selectedCity).toList();
    }

    // الميزانية
    if (_selectedBudgetRange != null) {
      final range = _budgetRanges.firstWhere(
        (r) => r['label'] == _selectedBudgetRange,
        orElse: () => _budgetRanges[0],
      );
      if (range['min'] != null || range['max'] != null) {
        filtered = filtered.where((ad) {
          if (range['min'] != null && ad.priceFrom < range['min']) return false;
          if (range['max'] != null && ad.priceTo > range['max']) return false;
          return true;
        }).toList();
      }
    }

    // نوع المطبخ
    if (_selectedKitchenType != null) {
      filtered = filtered.where((ad) => ad.kitchenType == _selectedKitchenType).toList();
    }

    // الخامة
    if (_selectedMaterial != null && _selectedMaterial != 'الكل') {
      filtered = filtered.where((ad) {
        return ad.material?.contains(_selectedMaterial!) ?? false;
      }).toList();
    }

    // مستوى الجودة
    if (_selectedQualityLevel != null && _selectedQualityLevel != 'الكل') {
      filtered = filtered.where((ad) {
        if (_selectedQualityLevel == 'اقتصادي') {
          return ad.kitchenType == KitchenType.economic;
        } else if (_selectedQualityLevel == 'فاخر') {
          return ad.kitchenType == KitchenType.luxury;
        }
        return true;
      }).toList();
    }

    // التقييم
    if (_minRating != null) {
      filtered = filtered.where((ad) => (ad.rating ?? 0) >= _minRating!).toList();
    }

    // الترتيب
    switch (_sortBy) {
      case 'recent':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'rating':
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case 'price_low':
        filtered.sort((a, b) => a.priceFrom.compareTo(b.priceFrom));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.priceFrom.compareTo(a.priceFrom));
        break;
      case 'views':
        filtered.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
    }

    setState(() {
      _filteredAds = filtered;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCity = null;
      _selectedBudgetRange = null;
      _selectedKitchenType = null;
      _selectedMaterial = null;
      _selectedQualityLevel = null;
      _minRating = null;
      _searchController.clear();
      _applyFiltersAndSort();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1000;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(theme),
        body: Row(
          children: [
            // الفلاتر الجانبية (على اليمين لأن RTL)
            if (isWide) _buildFiltersSidebar(theme),

            // منطقة النتائج
            Expanded(
              child: Column(
                children: [
                  // شريط الترتيب وعرض
                  _buildSortingBar(theme, isWide),

                  // النتائج
                  Expanded(
                    child: FutureBuilder<List<KitchenAd>>(
                      future: _adsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                                const SizedBox(height: 16),
                                Text('حدث خطأ: ${snapshot.error}'),
                              ],
                            ),
                          );
                        }

                        if (_filteredAds.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                const Text(
                                  'لا توجد نتائج',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text('جرب تغيير الفلاتر'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _clearFilters,
                                  child: const Text('مسح الفلاتر'),
                                ),
                              ],
                            ),
                          );
                        }

                        return _buildResultsGrid(isWide);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: !isWide
            ? FloatingActionButton.extended(
                onPressed: () => _showFiltersBottomSheet(context, theme),
                icon: const Icon(Icons.filter_list),
                label: const Text('فلترة'),
                backgroundColor: theme.colorScheme.primary,
              )
            : null,
      ),
    );
  }

  /// شريط علوي ثابت
  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.right,
                onSubmitted: (_) => _applyFiltersAndSort(),
                decoration: InputDecoration(
                  hintText: 'ابحث عن مطبخ...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: IconButton(
                    icon: Icon(Icons.search, color: theme.colorScheme.primary),
                    onPressed: _applyFiltersAndSort,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _applyFiltersAndSort();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // اختيار المدينة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              value: _selectedCity,
              hint: const Text('المدينة'),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down),
              items: _cities.map((city) {
                return DropdownMenuItem<String>(value: city, child: Text(city));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value == 'الكل' ? null : value;
                  _applyFiltersAndSort();
                });
              },
            ),
          ),
        ],
      ),
      actions: [
        // عدد النتائج
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${_filteredAds.length} نتيجة',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// قائمة الفلاتر الجانبية
  Widget _buildFiltersSidebar(ThemeData theme) {
    return Container(
      width: 300,
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الفلاتر',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('مسح الكل'),
              ),
            ],
          ),
          const Divider(height: 32),

          // الميزانية
          _buildFilterSection(
            'الميزانية',
            DropdownButton<String>(
              value: _selectedBudgetRange,
              hint: const Text('اختر النطاق'),
              isExpanded: true,
              underline: const SizedBox(),
              items: _budgetRanges.map((range) {
                return DropdownMenuItem<String>(
                  value: range['label'] as String,
                  child: Text(range['label'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBudgetRange = value;
                  _applyFiltersAndSort();
                });
              },
            ),
          ),

          const Divider(height: 32),

          // نوع المطبخ
          _buildFilterSection(
            'نوع المطبخ',
            Column(
              children: KitchenType.values.map((type) {
                return CheckboxListTile(
                  title: Text(_getKitchenTypeLabel(type)),
                  value: _selectedKitchenType == type,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (checked) {
                    setState(() {
                      _selectedKitchenType = checked! ? type : null;
                      _applyFiltersAndSort();
                    });
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(height: 32),

          // نوع الخامة
          _buildFilterSection(
            'نوع الخامة',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _materials.map((material) {
                final isSelected = _selectedMaterial == material;
                return FilterChip(
                  label: Text(material),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMaterial = selected ? material : null;
                      if (material == 'الكل') _selectedMaterial = null;
                      _applyFiltersAndSort();
                    });
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(height: 32),

          // مستوى الجودة
          _buildFilterSection(
            'مستوى الجودة',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _qualityLevels.map((level) {
                final isSelected = _selectedQualityLevel == level;
                return FilterChip(
                  label: Text(level),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedQualityLevel = selected ? level : null;
                      if (level == 'الكل') _selectedQualityLevel = null;
                      _applyFiltersAndSort();
                    });
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(height: 32),

          // تصنيف المعلن
          _buildFilterSection(
            'تصنيف المعلن',
            Column(
              children: [4.0, 3.0, 2.0].map((rating) {
                final isSelected = _minRating == rating;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _minRating = isSelected ? null : rating;
                      _applyFiltersAndSort();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (checked) {
                            setState(() {
                              _minRating = checked! ? rating : null;
                              _applyFiltersAndSort();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ...List.generate(5, (i) {
                          return Icon(
                            i < rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                        const Text(' فأكثر'),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  /// شريط الترتيب
  Widget _buildSortingBar(ThemeData theme, bool isWide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'ترتيب حسب:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('الأحدث', 'recent', theme),
                  _buildSortChip('الأعلى تقييماً', 'rating', theme),
                  _buildSortChip('الأقل سعراً', 'price_low', theme),
                  _buildSortChip('الأعلى سعراً', 'price_high', theme),
                  _buildSortChip('الأكثر مشاهدة', 'views', theme),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // تبديل العرض
          if (isWide)
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.grid_view,
                    color: _viewAsGrid ? theme.colorScheme.primary : null,
                  ),
                  onPressed: () => setState(() => _viewAsGrid = true),
                  tooltip: 'عرض شبكة',
                ),
                IconButton(
                  icon: Icon(
                    Icons.view_list,
                    color: !_viewAsGrid ? theme.colorScheme.primary : null,
                  ),
                  onPressed: () => setState(() => _viewAsGrid = false),
                  tooltip: 'عرض قائمة',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value, ThemeData theme) {
    final isSelected = _sortBy == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _sortBy = value;
            _applyFiltersAndSort();
          });
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      ),
    );
  }

  /// عرض النتائج
  Widget _buildResultsGrid(bool isWide) {
    if (_viewAsGrid) {
      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isWide ? 3 : 1,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: isWide ? 0.75 : 1.2,
        ),
        itemCount: _filteredAds.length,
        itemBuilder: (context, index) {
          return _buildKitchenCard(_filteredAds[index]);
        },
      );
    } else {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: _filteredAds.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildKitchenListItem(_filteredAds[index]),
          );
        },
      );
    }
  }

  /// بطاقة مطبخ (Grid View)
  Widget _buildKitchenCard(KitchenAd ad) {
    final isFavorite = _favorites.contains(ad.id);

    return InkWell(
      onTap: () {
        context.go('/kitchens/${ad.id}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ad.mainImage != null
                        ? Image.network(ad.mainImage!, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.kitchen, size: 48),
                          ),
                  ),
                ),
                // أيقونات سريعة
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    children: [
                      _buildIconButton(
                        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                        onTap: () {
                          setState(() {
                            if (isFavorite) {
                              _favorites.remove(ad.id);
                            } else {
                              _favorites.add(ad.id);
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(
                        icon: Icons.share,
                        color: Colors.white,
                        onTap: () {
                          // Share functionality
                        },
                      ),
                    ],
                  ),
                ),
                // شارة مميز
                if (ad.isFeatured)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC857),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.black87),
                          SizedBox(width: 4),
                          Text(
                            'مميز',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // التفاصيل
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم الإعلان
                    Text(
                      ad.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // اسم الشركة
                    Text(
                      ad.advertiserName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // المدينة + النوع
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          ad.city,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getKitchenTypeLabel(ad.kitchenType),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // السعر
                    Row(
                      children: [
                        Text(
                          '${ad.priceFrom.toStringAsFixed(0)} - ${ad.priceTo.toStringAsFixed(0)} ريال',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2962FF),
                          ),
                        ),
                      ],
                    ),

                    // التقييم
                    if (ad.rating != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            return Icon(
                              i < (ad.rating ?? 0).floor() ? Icons.star : Icons.star_border,
                              size: 14,
                              color: Colors.amber,
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            '${ad.rating?.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // تاغات
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (ad.hasInstallation) _buildTag('تصميم + تنفيذ', Icons.construction),
                        if (ad.warrantyYears != null && ad.warrantyYears! > 0)
                          _buildTag('ضمان ${ad.warrantyYears} سنوات', Icons.verified),
                        if (ad.completionDays != null && ad.completionDays! <= 30)
                          _buildTag('جاهز خلال ${ad.completionDays} يوم', Icons.schedule),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// عنصر مطبخ (List View)
  Widget _buildKitchenListItem(KitchenAd ad) {
    final isFavorite = _favorites.contains(ad.id);

    return InkWell(
      onTap: () {
        context.go('/kitchens/${ad.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 120,
                height: 90,
                child: ad.mainImage != null
                    ? Image.network(ad.mainImage!, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.kitchen),
                      ),
              ),
            ),

            const SizedBox(width: 12),

            // التفاصيل
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ad.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isFavorite) {
                              _favorites.remove(ad.id);
                            } else {
                              _favorites.add(ad.id);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  Text(
                    ad.advertiserName,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ad.priceFrom.toStringAsFixed(0)} - ${ad.priceTo.toStringAsFixed(0)} ريال',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2962FF),
                    ),
                  ),
                  if (ad.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        Text(' ${ad.rating?.toStringAsFixed(1)}'),
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

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.green.shade700),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// عرض الفلاتر في Bottom Sheet (للشاشات الصغيرة)
  void _showFiltersBottomSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الفلاتر',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                _clearFilters();
                                Navigator.pop(context);
                              },
                              child: const Text('مسح'),
                            ),
                            TextButton(
                              onPressed: () {
                                _applyFiltersAndSort();
                                Navigator.pop(context);
                              },
                              child: const Text('تطبيق'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // نفس محتوى الفلاتر الجانبية
                        // يمكن استخدام نفس الـ widgets
                        _buildFilterSection(
                          'الميزانية',
                          DropdownButton<String>(
                            value: _selectedBudgetRange,
                            hint: const Text('اختر النطاق'),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: _budgetRanges.map((range) {
                              return DropdownMenuItem<String>(
                                value: range['label'] as String,
                                child: Text(range['label'] as String),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setModalState(() {
                                setState(() {
                                  _selectedBudgetRange = value;
                                });
                              });
                            },
                          ),
                        ),
                        // ... بقية الفلاتر
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
