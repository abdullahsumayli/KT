import 'package:flutter/material.dart';

import '../services/admin_service.dart';
import 'admin_login_page.dart';
import 'analytics_page.dart';
import 'quote_details_page.dart';

/// صفحة لوحة تحكم المسؤول الرئيسية
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<Map<String, dynamic>> _quotes = [];
  bool _isLoading = true;
  String? _selectedStatus;
  String? _selectedStyle;
  String? _selectedCity;

  final List<Map<String, String>> _statusFilters = [
    {'id': 'all', 'label': 'الكل'},
    {'id': 'new', 'label': 'جديد'},
    {'id': 'contacted', 'label': 'تم التواصل'},
    {'id': 'quoted', 'label': 'تم إرسال السعر'},
    {'id': 'converted', 'label': 'تم التحويل'},
    {'id': 'lost', 'label': 'مفقود'},
  ];

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    setState(() => _isLoading = true);

    try {
      final quotes = await AdminService.fetchAllQuotes(
        status: _selectedStatus == 'all' ? null : _selectedStatus,
        style: _selectedStyle,
        city: _selectedCity,
      );

      if (mounted) {
        setState(() {
          _quotes = quotes;
          _isLoading = false;
        });
      }
    } on AdminAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const AdminLoginPage()));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _handleLogout() async {
    await AdminService.logout();
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AdminLoginPage()));
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'contacted':
        return Colors.orange;
      case 'quoted':
        return Colors.purple;
      case 'converted':
        return Colors.green;
      case 'lost':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'new':
        return 'جديد';
      case 'contacted':
        return 'تم التواصل';
      case 'quoted':
        return 'تم إرسال السعر';
      case 'converted':
        return 'تم التحويل';
      case 'lost':
        return 'مفقود';
      default:
        return status;
    }
  }

  String _getStyleLabel(String style) {
    switch (style) {
      case 'modern':
        return 'مودرن';
      case 'classic':
        return 'كلاسيك';
      case 'wood':
        return 'خشب';
      case 'aluminum':
        return 'ألمنيوم';
      default:
        return style;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة تحكم المسؤول', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AnalyticsPage()));
              },
              tooltip: 'الإحصائيات',
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadQuotes, tooltip: 'تحديث'),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('تسجيل الخروج'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') _handleLogout();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Filters
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  // Status Filter
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _statusFilters.length,
                      itemBuilder: (context, index) {
                        final filter = _statusFilters[index];
                        final isSelected =
                            _selectedStatus == filter['id'] ||
                            (_selectedStatus == null && filter['id'] == 'all');

                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: FilterChip(
                            label: Text(filter['label']!),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus = filter['id'] == 'all' ? null : filter['id'];
                              });
                              _loadQuotes();
                            },
                            selectedColor: Colors.teal.shade100,
                            checkmarkColor: Colors.teal.shade700,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Quotes List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _quotes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد طلبات',
                            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadQuotes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _quotes.length,
                        itemBuilder: (context, index) {
                          final quote = _quotes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => QuoteDetailsPage(quoteId: quote['id']),
                                  ),
                                );
                                if (result == true) _loadQuotes();
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              quote['status'],
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: _getStatusColor(
                                                quote['status'],
                                              ).withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            _getStatusLabel(quote['status']),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusColor(quote['status']),
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '#${quote['id']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.phone, size: 20, color: Colors.grey.shade600),
                                        const SizedBox(width: 8),
                                        Text(
                                          quote['phone'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.kitchen, size: 18, color: Colors.grey.shade600),
                                        const SizedBox(width: 8),
                                        Text(
                                          _getStyleLabel(quote['style']),
                                          style: TextStyle(color: Colors.grey.shade700),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.location_on,
                                          size: 18,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          quote['city'] ?? '-',
                                          style: TextStyle(color: Colors.grey.shade700),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatDate(quote['created_at']),
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                    ),
                                  ],
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _loadQuotes,
          backgroundColor: Colors.teal.shade600,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.refresh),
          label: const Text('تحديث'),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
