import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/admin_service.dart';

/// صفحة الإحصائيات والتحليلات
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final stats = await AdminService.fetchStats();

      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
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

  Color _getStatusColor(String status) {
    // Handle both "new" and "QuoteRequestStatus.NEW" formats
    final cleanStatus = status.replaceAll('QuoteRequestStatus.', '').toLowerCase();
    switch (cleanStatus) {
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
    // Handle both "new" and "QuoteRequestStatus.NEW" formats
    final cleanStatus = status.replaceAll('QuoteRequestStatus.', '').toLowerCase();
    switch (cleanStatus) {
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
        return cleanStatus;
    }
  }

  String _getStyleLabel(String style) {
    // Handle both "modern" and "KitchenStyle.MODERN" formats
    final cleanStyle = style.replaceAll('KitchenStyle.', '').toLowerCase();
    switch (cleanStyle) {
      case 'modern':
        return 'مودرن';
      case 'classic':
        return 'كلاسيك';
      case 'wood':
        return 'خشب';
      case 'aluminum':
        return 'ألمنيوم';
      default:
        return cleanStyle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإحصائيات والتحليلات', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats, tooltip: 'تحديث'),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _stats == null
            ? const Center(child: Text('لا توجد بيانات'))
            : RefreshIndicator(
                onRefresh: _loadStats,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Total Requests Card
                      Card(
                        elevation: 4,
                        color: Colors.teal.shade700,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Icon(Icons.assessment, size: 48, color: Colors.white),
                              const SizedBox(height: 12),
                              const Text(
                                'إجمالي الطلبات',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_stats!['total'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Status Distribution
                      const Text(
                        'التوزيع حسب الحالة',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ..._buildDistributionCards(
                        _stats!['by_status'] as Map<String, dynamic>? ?? {},
                        _getStatusLabel,
                        _getStatusColor,
                      ),
                      const SizedBox(height: 24),

                      // Style Distribution
                      const Text(
                        'التوزيع حسب نوع المطبخ',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ..._buildDistributionCards(
                        _stats!['by_style'] as Map<String, dynamic>? ?? {},
                        _getStyleLabel,
                        (key) => Colors.blue.shade700,
                      ),
                      const SizedBox(height: 24),

                      // City Distribution
                      const Text(
                        'التوزيع حسب المدينة',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ..._buildCityDistribution(_stats!['by_city'] as Map<String, dynamic>? ?? {}),

                      const SizedBox(height: 24),

                      // Conversion Rate Card (if converted exists)
                      if (_stats!['by_status'] != null) _buildConversionRateCard(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildDistributionCards(
    Map<String, dynamic> distribution,
    String Function(String) getLabel,
    Color Function(String) getColor,
  ) {
    final total = _stats!['total'] ?? 1;
    final items = distribution.entries.toList();

    return items.map((entry) {
      final percentage = ((entry.value / total) * 100).toStringAsFixed(1);

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: getColor(entry.key).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${entry.value}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: getColor(entry.key),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getLabel(entry.key),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entry.value / total,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(getColor(entry.key)),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: getColor(entry.key),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildCityDistribution(Map<String, dynamic> distribution) {
    final total = _stats!['total'] ?? 1;
    final items = distribution.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));

    final colors = [
      Colors.blue.shade700,
      Colors.purple.shade700,
      Colors.orange.shade700,
      Colors.green.shade700,
    ];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final city = entry.value;
      final percentage = ((city.value / total) * 100).toStringAsFixed(1);
      final color = colors[index % colors.length];

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.location_city, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.key,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: city.value / total,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${city.value}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  ),
                  Text('$percentage%', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildConversionRateCard() {
    final total = _stats!['total'] ?? 1;

    // Find converted count from by_status
    int converted = 0;
    final byStatus = _stats!['by_status'] as Map<String, dynamic>? ?? {};
    byStatus.forEach((key, value) {
      final cleanKey = key.replaceAll('QuoteRequestStatus.', '').toLowerCase();
      if (cleanKey == 'converted') {
        converted = value as int;
      }
    });

    final conversionRate = ((converted / total) * 100).toStringAsFixed(1);

    return Card(
      elevation: 4,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
              child: Icon(Icons.trending_up, size: 32, color: Colors.green.shade700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معدل التحويل',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$conversionRate%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  Text(
                    '$converted من أصل $total',
                    style: TextStyle(fontSize: 12, color: Colors.green.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
