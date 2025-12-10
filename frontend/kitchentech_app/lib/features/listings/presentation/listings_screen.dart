import 'package:flutter/material.dart';

import '../../../shared/widgets/shared_widgets.dart';
import '../../listings/presentation/widgets/kitchen_card.dart';

class ListingsScreen extends StatefulWidget {
  final String? searchQuery;
  final String? category;

  const ListingsScreen({
    super.key,
    this.searchQuery,
    this.category,
  });

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  final List<String> filters = ['الكل', 'جاهز', 'تفصيل'];
  String selectedFilter = 'الكل';

  // Mock data
  final List<Map<String, dynamic>> listings = [
    {
      'id': '1',
      'title': 'مطبخ حديث مع جزيرة',
      'city': 'الرياض',
      'price': 45000.0,
      'type': 'جاهز',
      'aiScore': 9.2,
      'imageUrl': 'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=800&h=600&fit=crop',
    },
    {
      'id': '2',
      'title': 'مطبخ عصري تفصيل',
      'city': 'جدة',
      'price': 3500.0,
      'type': 'تفصيل',
      'aiScore': 8.7,
      'imageUrl': 'https://images.unsplash.com/photo-1556909172-54557c7e4fb7?w=800&h=600&fit=crop',
    },
    {
      'id': '3',
      'title': 'مطبخ خشبي كلاسيكي',
      'city': 'الدمام',
      'price': 38000.0,
      'type': 'جاهز',
      'aiScore': 8.5,
      'imageUrl': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=600&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      selectedFilter = widget.category!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('تصفح الإعلانات'),
            const SizedBox(width: 8),
            Image.asset(
              'assets/images/logo.png',
              height: 28,
              fit: BoxFit.contain,
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2962FF),
                Color(0xFF1976D2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Bar with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.blue.shade50.withOpacity(0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'تصفية النتائج',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2962FF),
                            Color(0xFF1976D2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilterBarRtl(
                  filters: filters,
                  selectedFilter: selectedFilter,
                  onFilterSelected: (filter) {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                ),
              ],
            ),
          ),

          // Listings
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: listings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final listing = listings[index];
                return SizedBox(
                  height: 220,
                  child: KitchenCard(
                    id: listing['id'],
                    title: listing['title'],
                    city: listing['city'],
                    price: listing['price'],
                    type: listing['type'],
                    aiScore: listing['aiScore'],
                    imageUrl: listing['imageUrl'],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2962FF),
              Color(0xFF1976D2),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2962FF).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/add-listing');
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add),
          label: const Text(
            'أضف إعلان',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
