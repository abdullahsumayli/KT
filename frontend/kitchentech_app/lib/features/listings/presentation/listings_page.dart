import 'package:flutter/material.dart';

import '../data/listings_api.dart';
import '../models/kitchen_listing.dart';

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  final ListingsApi _api = ListingsApi();

  List<KitchenListing> _listings = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter values
  String _selectedCity = 'الكل';
  String _selectedType = 'الكل';
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _fetchListings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final minPrice =
          _minPriceController.text.isNotEmpty ? double.tryParse(_minPriceController.text) : null;
      final maxPrice =
          _maxPriceController.text.isNotEmpty ? double.tryParse(_maxPriceController.text) : null;

      final listings = await _api.fetchListings(
        city: _selectedCity != 'الكل' ? _selectedCity : null,
        type: _selectedType != 'الكل' ? _selectedType : null,
        minPrice: minPrice,
        maxPrice: maxPrice,
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

  int _getGridColumns(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تصفّح المطابخ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add-listing').then((_) {
                // Refresh listings after returning
                _fetchListings();
              });
            },
            tooltip: 'أضف مطبخك',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Bar
          _buildFiltersBar(),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: Column(
        children: [
          Row(
            children: [
              // City filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCity,
                  decoration: const InputDecoration(
                    labelText: 'المدينة',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                    DropdownMenuItem(value: 'الرياض', child: Text('الرياض')),
                    DropdownMenuItem(value: 'جدة', child: Text('جدة')),
                    DropdownMenuItem(value: 'الدمام', child: Text('الدمام')),
                    DropdownMenuItem(value: 'مكة', child: Text('مكة')),
                    DropdownMenuItem(value: 'المدينة', child: Text('المدينة')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value ?? 'الكل';
                    });
                    _fetchListings();
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Type filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'النوع',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                    DropdownMenuItem(value: 'جديد', child: Text('جديد')),
                    DropdownMenuItem(value: 'مستعمل', child: Text('مستعمل')),
                    DropdownMenuItem(value: 'جاهز', child: Text('جاهز')),
                    DropdownMenuItem(value: 'تفصيل', child: Text('تفصيل')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value ?? 'الكل';
                    });
                    _fetchListings();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Min price
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  decoration: const InputDecoration(
                    labelText: 'السعر الأدنى',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    prefixText: 'ر.س ',
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _fetchListings(),
                ),
              ),
              const SizedBox(width: 8),

              // Max price
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  decoration: const InputDecoration(
                    labelText: 'السعر الأعلى',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    prefixText: 'ر.س ',
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _fetchListings(),
                ),
              ),
              const SizedBox(width: 8),

              // Search button
              ElevatedButton.icon(
                onPressed: _fetchListings,
                icon: const Icon(Icons.search),
                label: const Text('بحث'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchListings,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_listings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد مطابخ متاحة',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _getGridColumns(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _listings.length,
          itemBuilder: (context, index) {
            return _buildListingCard(_listings[index]);
          },
        );
      },
    );
  }

  Widget _buildListingCard(KitchenListing listing) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 140,
            width: double.infinity,
            color: Colors.orange[100],
            child: const Icon(
              Icons.kitchen,
              size: 64,
              color: Colors.orange,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Featured badge
                if (listing.isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'مميز',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),

                // Title
                Text(
                  listing.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Price
                Text(
                  '${listing.price.toStringAsFixed(0)} ر.س',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),

                // City and Type
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      listing.city,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${listing.type}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),

                // Dimensions if available
                if (listing.lengthM != null || listing.widthM != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'الأبعاد: ${listing.lengthM?.toStringAsFixed(1) ?? '?'} × ${listing.widthM?.toStringAsFixed(1) ?? '?'} م',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
