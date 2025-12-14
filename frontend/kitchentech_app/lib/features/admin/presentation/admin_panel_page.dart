import 'package:flutter/material.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 1200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'الإشعارات',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
            tooltip: 'الإعدادات',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: !isWide,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'نظرة عامة'),
            Tab(icon: Icon(Icons.people), text: 'المستخدمين'),
            Tab(icon: Icon(Icons.kitchen), text: 'الإعلانات'),
            Tab(icon: Icon(Icons.analytics), text: 'الإحصائيات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(colorScheme, isWide),
          _buildUsersTab(colorScheme),
          _buildAdsTab(colorScheme),
          _buildAnalyticsTab(colorScheme),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ColorScheme colorScheme, bool isWide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً، المدير',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'آخر تحديث: ${DateTime.now().toString().substring(0, 16)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Stats Cards
          GridView.count(
            crossAxisCount: isWide ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isWide ? 1.5 : 1.3,
            children: [
              _buildStatCard(
                title: 'إجمالي المستخدمين',
                value: '1,234',
                icon: Icons.people,
                color: colorScheme.primary,
                trend: '+12%',
                isPositive: true,
              ),
              _buildStatCard(
                title: 'إجمالي الإعلانات',
                value: '856',
                icon: Icons.kitchen,
                color: Colors.orange,
                trend: '+8%',
                isPositive: true,
              ),
              _buildStatCard(
                title: 'إعلانات قيد المراجعة',
                value: '23',
                icon: Icons.pending_actions,
                color: Colors.amber,
                trend: '-5%',
                isPositive: false,
              ),
              _buildStatCard(
                title: 'الإيرادات الشهرية',
                value: '125,000',
                icon: Icons.payments,
                color: Colors.green,
                trend: '+18%',
                isPositive: true,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent Activity
          Text(
            'النشاطات الأخيرة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      _getActivityIcon(index),
                      color: colorScheme.primary,
                    ),
                  ),
                  title: Text(_getActivityTitle(index)),
                  subtitle: Text(_getActivityTime(index)),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(ColorScheme colorScheme) {
    return Column(
      children: [
        // Search and Filter Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'البحث عن مستخدم...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
                label: const Text('تصفية'),
              ),
            ],
          ),
        ),

        // Users List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 10,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text('م${index + 1}'),
                ),
                title: Text('مستخدم ${index + 1}'),
                subtitle: Text('user${index + 1}@example.com'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(index % 2 == 0 ? 'مشتري' : 'معلن'),
                      backgroundColor: index % 2 == 0 ? Colors.blue[100] : Colors.orange[100],
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showUserMenu(context),
                    ),
                  ],
                ),
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdsTab(ColorScheme colorScheme) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'قيد المراجعة'),
              Tab(text: 'نشط'),
              Tab(text: 'مرفوض'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAdsList(colorScheme, 'pending'),
                _buildAdsList(colorScheme, 'active'),
                _buildAdsList(colorScheme, 'rejected'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdsList(ColorScheme colorScheme, String status) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.kitchen),
            ),
            title: Text('مطبخ ${index + 1}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('المعلن: معلن ${index + 1}'),
                const SizedBox(height: 4),
                Text(
                  'تاريخ النشر: ${DateTime.now().subtract(Duration(days: index)).toString().substring(0, 10)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: status == 'pending'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _showApprovalDialog(context, true),
                        tooltip: 'قبول',
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _showApprovalDialog(context, false),
                        tooltip: 'رفض',
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {},
                  ),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإحصائيات والتحليلات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // Revenue Chart Placeholder
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإيرادات الشهرية',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('مخطط الإيرادات الشهرية'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // User Growth Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نمو عدد المستخدمين',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('مخطط نمو المستخدمين'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Top Advertisers
          Text(
            'أفضل المعلنين',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text('${index + 1}'),
                  ),
                  title: Text('معلن ${index + 1}'),
                  subtitle: Text('${25 - index * 3} إعلان نشط'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${4.8 - index * 0.1}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    required bool isPositive,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 11,
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(int index) {
    final icons = [
      Icons.person_add,
      Icons.kitchen,
      Icons.payment,
      Icons.check_circle,
      Icons.report_problem,
    ];
    return icons[index % icons.length];
  }

  String _getActivityTitle(int index) {
    final titles = [
      'مستخدم جديد: أحمد محمد',
      'إعلان جديد: مطبخ إيطالي فاخر',
      'دفعة جديدة: 5,000 ر.س',
      'تم الموافقة على إعلان',
      'تم الإبلاغ عن محتوى',
    ];
    return titles[index % titles.length];
  }

  String _getActivityTime(int index) {
    return 'منذ ${index + 1} ${index == 0 ? 'دقيقة' : 'دقائق'}';
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('عرض التفاصيل'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('حظر المستخدم'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف الحساب', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showApprovalDialog(BuildContext context, bool isApproval) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApproval ? 'قبول الإعلان' : 'رفض الإعلان'),
        content: Text(
          isApproval ? 'هل أنت متأكد من قبول هذا الإعلان؟' : 'هل أنت متأكد من رفض هذا الإعلان؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isApproval ? 'تم قبول الإعلان' : 'تم رفض الإعلان',
                  ),
                  backgroundColor: isApproval ? Colors.green : Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: isApproval ? Colors.green : Colors.red,
            ),
            child: Text(isApproval ? 'قبول' : 'رفض'),
          ),
        ],
      ),
    );
  }
}
