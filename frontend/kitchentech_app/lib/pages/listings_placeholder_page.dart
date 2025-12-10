import 'package:flutter/material.dart';

import '../features/listings/data/listings_api.dart';
import '../features/listings/models/kitchen_listing.dart';

class ListingsPlaceholderPage extends StatefulWidget {
  const ListingsPlaceholderPage({super.key});

  @override
  State<ListingsPlaceholderPage> createState() => _ListingsPlaceholderPageState();
}

class _ListingsPlaceholderPageState extends State<ListingsPlaceholderPage> {
  final ListingsApi _api = ListingsApi();
  List<KitchenListing> _listings = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter values
  String _selectedCity = 'الكل';
  String _selectedType = 'الكل';

  final Map<String, String> _cityMap = {
    'الكل': '',
    'الرياض': 'riyadh',
    'جدة': 'jeddah',
    'الدمام': 'dammam',
  };

  final Map<String, String> _typeMap = {
    'الكل': '',
    'جديد': 'new',
    'مستعمل': 'used',
    'جاهز': 'ready',
    'تفصيل': 'custom',
  };

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  Future<void> _fetchListings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final city = _cityMap[_selectedCity];
      final type = _typeMap[_selectedType];

      final listings = await _api.fetchListings(
        city: city?.isNotEmpty == true ? city : null,
        type: type?.isNotEmpty == true ? type : null,
      );

      setState(() {
        _listings = listings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تصفّح المطابخ'),
        backgroundColor: Colors.deepOrange.shade50,
      ),
      body: Column(
        children: [
          // Filters section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCity,
                    decoration: const InputDecoration(
                      labelText: 'المدينة',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _cityMap.keys.map((city) {
                      return DropdownMenuItem(value: city, child: Text(city));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value ?? 'الكل';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'النوع',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _typeMap.keys.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value ?? 'الكل';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _fetchListings,
                  icon: const Icon(Icons.search),
                  label: const Text('بحث'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),

          // Content section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _fetchListings,
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      )
                    : _listings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.kitchen_outlined, size: 80, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد مطابخ متاحة حاليًا',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'كن أول من يضيف مطبخًا!',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/add-listing');
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('أضف مطبخك الآن'),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide ? 3 : 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: _listings.length,
                            itemBuilder: (context, index) {
                              final listing = _listings[index];
                              return _KitchenCard(listing: listing);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/add-listing');
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة مطبخ'),
      ),
    );
  }
}

class _KitchenCard extends StatelessWidget {
  final KitchenListing listing;

  const _KitchenCard({required this.listing});

  String _getTypeArabic(String type) {
    switch (type) {
      case 'new':
        return 'جديد';
      case 'used':
        return 'مستعمل';
      case 'ready':
        return 'جاهز';
      case 'custom':
        return 'تفصيل';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image placeholder
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.brown.shade300,
                        Colors.deepOrange.shade200,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.kitchen, size: 48, color: Colors.white),
                  ),
                ),
                if (listing.isFeatured)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'مميز',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'السعر: ${listing.price.toStringAsFixed(0)} ر.س',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        listing.city,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getTypeArabic(listing.type),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: Colors.grey[700],
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
