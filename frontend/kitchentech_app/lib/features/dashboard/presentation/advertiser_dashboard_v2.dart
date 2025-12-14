import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// صفحة لوحة تحكم المعلن - Spec 2.5
class AdvertiserDashboardV2 extends StatefulWidget {
  const AdvertiserDashboardV2({super.key});

  @override
  State<AdvertiserDashboardV2> createState() => _AdvertiserDashboardV2State();
}

class _AdvertiserDashboardV2State extends State<AdvertiserDashboardV2> {
  int _selectedIndex = 0;

  final List<String> _menuItems = [
    'نظرة عامة',
    'إدارة الإعلانات',
    'الباقات والاشتراكات',
    'الإعدادات',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1000;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Row(
            children: [
              Icon(Icons.kitchen, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              const Text(
                'لوحة تحكم المعلن',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لا توجد إشعارات جديدة')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Text(
                  'م',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Row(
          children: [
            // Sidebar
            if (isWide) _buildSidebar(),
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
        drawer: isWide ? null : _buildDrawer(),
        floatingActionButton: _selectedIndex == 1
            ? FloatingActionButton.extended(
                onPressed: () {
                  context.go('/dashboard/new-ad');
                },
                icon: const Icon(Icons.add),
                label: const Text('إعلان جديد'),
              )
            : null,
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 24),
          // صورة المعلن
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.business,
              size: 50,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'مؤسسة المطابخ الفاخرة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'باقة ذهبية',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // القائمة
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  leading: Icon(
                    _getMenuIcon(index),
                    color:
                        isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade600,
                  ),
                  title: Text(
                    _menuItems[index],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade800,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.home_outlined, color: Colors.grey.shade600),
            title: Text(
              'العودة للرئيسية',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            onTap: () => context.go('/'),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade400),
            title: Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red.shade400),
            ),
            onTap: () {
              context.go('/auth/login');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: _buildSidebar(),
    );
  }

  IconData _getMenuIcon(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard_outlined;
      case 1:
        return Icons.article_outlined;
      case 2:
        return Icons.card_membership_outlined;
      case 3:
        return Icons.settings_outlined;
      default:
        return Icons.circle;
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildAdsManagement();
      case 2:
        return _buildSubscriptions();
      case 3:
        return _buildSettings();
      default:
        return _buildOverview();
    }
  }

  // ==================== نظرة عامة ====================
  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نظرة عامة',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // الإحصائيات
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard(
                    title: 'الإعلانات النشطة',
                    value: '12',
                    icon: Icons.article,
                    color: Colors.blue,
                    width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                  ),
                  _buildStatCard(
                    title: 'الزيارات هذا الشهر',
                    value: '2,543',
                    icon: Icons.visibility,
                    color: Colors.green,
                    width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                  ),
                  _buildStatCard(
                    title: 'نقرات التواصل',
                    value: '187',
                    icon: Icons.phone,
                    color: Colors.orange,
                    width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                  ),
                  _buildStatCard(
                    title: 'معدل التحويل',
                    value: '7.4%',
                    icon: Icons.trending_up,
                    color: Colors.purple,
                    width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          // أفضل إعلان أداءً
          const Text(
            'أفضل إعلان أداءً هذا الشهر',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTopPerformingAd(),
          const SizedBox(height: 32),
          // الإعلانات الأخيرة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإعلانات الأخيرة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecentAdsList(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Icon(Icons.arrow_upward, color: Colors.green.shade400, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformingAd() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 120,
              height: 80,
              color: Colors.grey.shade300,
              child: const Icon(Icons.kitchen, size: 40),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مطبخ مودرن فاخر - تصميم إيطالي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('845 زيارة', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(width: 16),
                    Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('67 نقرة', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 4),
                Text(
                  'مميز',
                  style: TextStyle(
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAdsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildAdListItem(
          title: 'مطبخ ${['كلاسيك', 'عصري', 'اقتصادي'][index]}',
          status: ['نشط', 'بانتظار المراجعة', 'نشط'][index],
          views: [234, 45, 567][index],
          contacts: [12, 2, 34][index],
        );
      },
    );
  }

  Widget _buildAdListItem({
    required String title,
    required String status,
    required int views,
    required int contacts,
  }) {
    Color statusColor;
    switch (status) {
      case 'نشط':
        statusColor = Colors.green;
        break;
      case 'بانتظار المراجعة':
        statusColor = Colors.orange;
        break;
      case 'مرفوض':
        statusColor = Colors.red;
        break;
      case 'منتهي':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.kitchen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.visibility, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('$views', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(width: 12),
                    Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('$contacts', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== إدارة الإعلانات ====================
  Widget _buildAdsManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إدارة الإعلانات',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/dashboard/new-ad');
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة إعلان جديد'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildAdsTable(),
        ],
      ),
    );
  }

  Widget _buildAdsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('عنوان الإعلان', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2, child: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('تاريخ النشر', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1,
                    child: Text('الزيارات', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1, child: Text('التواصل', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2, child: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              return _buildAdTableRow(
                title: 'مطبخ ${[
                  'مودرن فاخر',
                  'كلاسيك أنيق',
                  'اقتصادي عملي',
                  'نيو كلاسيك',
                  'مفتوح عصري',
                  'منفصل تقليدي',
                  'للفلل الفاخرة',
                  'للشقق الصغيرة'
                ][index]}',
                status: [
                  'نشط',
                  'بانتظار المراجعة',
                  'نشط',
                  'مرفوض',
                  'نشط',
                  'منتهي',
                  'نشط',
                  'نشط'
                ][index],
                date: '2024-${12 - (index % 3)}-${15 + index}',
                views: [845, 234, 567, 120, 890, 345, 678, 432][index],
                contacts: [67, 12, 34, 5, 56, 23, 45, 28][index],
                isFeatured: index % 3 == 0,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdTableRow({
    required String title,
    required String status,
    required String date,
    required int views,
    required int contacts,
    required bool isFeatured,
  }) {
    Color statusColor;
    switch (status) {
      case 'نشط':
        statusColor = Colors.green;
        break;
      case 'بانتظار المراجعة':
        statusColor = Colors.orange;
        break;
      case 'مرفوض':
        statusColor = Colors.red;
        break;
      case 'منتهي':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.kitchen, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isFeatured) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'مميز',
                              style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              views.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              contacts.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تعديل: $title')),
                    );
                  },
                  tooltip: 'تعديل',
                ),
                IconButton(
                  icon: Icon(
                    status == 'نشط' ? Icons.pause_circle_outline : Icons.play_circle_outline,
                    size: 20,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(status == 'نشط' ? 'تم إيقاف الإعلان' : 'تم تفعيل الإعلان'),
                      ),
                    );
                  },
                  tooltip: status == 'نشط' ? 'إيقاف' : 'تفعيل',
                ),
                if (!isFeatured)
                  IconButton(
                    icon: Icon(Icons.star_outline, size: 20, color: Colors.amber.shade700),
                    onPressed: () {
                      _showFeatureDialog(title);
                    },
                    tooltip: 'ترقية لمميز',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatureDialog(String adTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ترقية إلى إعلان مميز'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد ترقية "$adTitle" إلى إعلان مميز؟'),
            const SizedBox(height: 16),
            Text(
              'المميزات:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            _buildFeature('ظهور في الصفحة الرئيسية'),
            _buildFeature('علامة "مميز" ذهبية'),
            _buildFeature('أولوية في نتائج البحث'),
            _buildFeature('زيادة الزيارات بنسبة 300%'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('السعر:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '500 ريال/شهر',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم ترقية الإعلان بنجاح!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('تأكيد الترقية'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // ==================== الباقات والاشتراكات ====================
  Widget _buildSubscriptions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الباقات والاشتراكات',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // الباقة الحالية
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.shade400,
                  Colors.amber.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'باقتك الحالية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'نشطة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'الباقة الذهبية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '2,500 ريال / سنوياً',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'تاريخ الانتهاء: ',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '15 يوليو 2025',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerRight,
                    widthFactor: 0.65,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'متبقي 7 أشهر',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // مميزات الباقة الحالية
          const Text(
            'مميزات باقتك الحالية',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildPlanFeature('20 إعلان نشط', Icons.article),
              _buildPlanFeature('5 إعلانات مميزة', Icons.star),
              _buildPlanFeature('إحصائيات متقدمة', Icons.analytics),
              _buildPlanFeature('دعم أولوية', Icons.support_agent),
              _buildPlanFeature('شعار الشركة', Icons.business),
              _buildPlanFeature('صفحة مخصصة', Icons.web),
            ],
          ),
          const SizedBox(height: 32),
          // الباقات المتاحة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ترقية الباقة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.go('/plans');
                },
                child: const Text('عرض جميع الباقات'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAvailablePlans(),
          const SizedBox(height: 32),
          // سجل الفواتير
          const Text(
            'سجل الفواتير',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInvoicesTable(),
        ],
      ),
    );
  }

  Widget _buildPlanFeature(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAvailablePlans() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildPlanOption(
            name: 'الباقة البلاتينية',
            price: '5,000',
            features: ['50 إعلان', '15 إعلان مميز', 'أولوية قصوى', 'حساب مدير'],
            color: Colors.grey.shade700,
            recommended: true,
          ),
          const Divider(height: 32),
          _buildPlanOption(
            name: 'الباقة الماسية',
            price: '10,000',
            features: ['إعلانات غير محدودة', '30 إعلان مميز', 'حلول مخصصة', 'API خاص'],
            color: Colors.blue.shade700,
            recommended: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption({
    required String name,
    required String price,
    required List<String> features,
    required Color color,
    required bool recommended,
  }) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.workspace_premium, color: color, size: 32),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (recommended) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'موصى به',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$price ريال/سنوياً',
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: features
                    .map((f) =>
                        Text('• $f', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)))
                    .toList(),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('الترقية إلى $name')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
          ),
          child: const Text('ترقية'),
        ),
      ],
    );
  }

  Widget _buildInvoicesTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('رقم الفاتورة', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2, child: Text('التاريخ', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2, child: Text('الباقة', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1, child: Text('المبلغ', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1, child: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text('INV-2024-${1234 + index}')),
                    Expanded(flex: 2, child: Text('2024-${12 - index * 3}-15')),
                    Expanded(
                        flex: 2, child: Text(['الذهبية', 'الذهبية', 'الفضية', 'البرونزية'][index])),
                    Expanded(flex: 1, child: Text('${[2500, 2500, 1500, 500][index]} ريال')),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'مدفوعة',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: const Icon(Icons.download, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('جاري تحميل الفاتورة...')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== الإعدادات ====================
  Widget _buildSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الإعدادات',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // بيانات الشركة
          _buildSettingsSection(
            title: 'بيانات الشركة',
            icon: Icons.business,
            children: [
              _buildTextField('اسم الشركة', 'مؤسسة المطابخ الفاخرة'),
              _buildTextField('نوع المعلن', 'شركة'),
              _buildTextField('المدينة', 'الرياض'),
              _buildTextField('رقم السجل التجاري', '1234567890'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ التغييرات')),
                  );
                },
                child: const Text('حفظ التغييرات'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // بيانات التواصل
          _buildSettingsSection(
            title: 'بيانات التواصل',
            icon: Icons.contact_mail,
            children: [
              _buildTextField('البريد الإلكتروني', 'info@company.com'),
              _buildTextField('رقم الجوال', '0501234567'),
              _buildTextField('الموقع الإلكتروني', 'www.company.com'),
              _buildTextField('حساب إنستغرام', '@company'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ التغييرات')),
                  );
                },
                child: const Text('حفظ التغييرات'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // شعار الشركة
          _buildSettingsSection(
            title: 'شعار الشركة',
            icon: Icons.image,
            children: [
              Row(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Icon(Icons.business, size: 60, color: Colors.grey.shade400),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ارفع شعار شركتك',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'الحجم الموصى به: 500x500 بكسل\nالصيغ المقبولة: JPG, PNG',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('اختر صورة من جهازك')),
                            );
                          },
                          icon: const Icon(Icons.upload),
                          label: const Text('رفع شعار'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // الإشعارات
          _buildSettingsSection(
            title: 'الإشعارات',
            icon: Icons.notifications,
            children: [
              _buildSwitchTile('إشعارات البريد الإلكتروني', true),
              _buildSwitchTile('إشعارات الرسائل النصية', false),
              _buildSwitchTile('إشعارات الإعلانات الجديدة', true),
              _buildSwitchTile('إشعارات التواصل من العملاء', true),
              _buildSwitchTile('إشعارات انتهاء الباقة', true),
            ],
          ),
          const SizedBox(height: 24),
          // تغيير كلمة المرور
          _buildSettingsSection(
            title: 'الأمان',
            icon: Icons.security,
            children: [
              _buildTextField('كلمة المرور الحالية', '', obscureText: true),
              _buildTextField('كلمة المرور الجديدة', '', obscureText: true),
              _buildTextField('تأكيد كلمة المرور الجديدة', '', obscureText: true),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تغيير كلمة المرور')),
                  );
                },
                child: const Text('تغيير كلمة المرور'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool value = initialValue;
        return SwitchListTile(
          title: Text(title),
          value: value,
          onChanged: (newValue) {
            setState(() {
              value = newValue;
            });
          },
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }
}
