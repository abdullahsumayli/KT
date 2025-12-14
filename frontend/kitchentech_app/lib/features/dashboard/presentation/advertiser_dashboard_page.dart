import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/data/models/advertiser.dart';
import '../../shared/data/models/kitchen_ad.dart';
import '../../shared/data/repositories/kitchen_ads_repository.dart';

/// لوحة تحكم المعلن
class AdvertiserDashboardPage extends StatefulWidget {
  const AdvertiserDashboardPage({super.key});

  @override
  State<AdvertiserDashboardPage> createState() => _AdvertiserDashboardPageState();
}

class _AdvertiserDashboardPageState extends State<AdvertiserDashboardPage> {
  final KitchenAdsRepository _repository = MockKitchenAdsRepository();
  int _selectedIndex = 0;

  // Mock advertiser data - in real app, get from auth
  final Advertiser _currentAdvertiser = Advertiser(
    id: 'adv1',
    companyName: 'مطابخ الفخامة',
    type: AdvertiserType.company,
    email: 'info@luxury-kitchens.sa',
    phone: '0501234567',
    city: 'الرياض',
    rating: 4.8,
    totalAds: 8,
    activeAds: 5,
    joinedAt: DateTime(2023, 1, 15),
    currentPlanId: 'pro',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'إعلاناتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'الإحصائيات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/dashboard/new-ad'),
              icon: const Icon(Icons.add),
              label: const Text('إعلان جديد'),
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildMyAds();
      case 2:
        return _buildAnalytics();
      case 3:
        return _buildSettings();
      default:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            elevation: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _currentAdvertiser.companyName[0],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مرحباً، ${_currentAdvertiser.companyName}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_currentAdvertiser.rating != null)
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber[700]),
                              const SizedBox(width: 4),
                              Text(
                                _currentAdvertiser.rating!.toStringAsFixed(1),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                ' (${_currentAdvertiser.totalAds} إعلان)',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Plan Card
          Card(
            color: Colors.amber[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium, color: Colors.amber[700], size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'خطة ${_currentAdvertiser.currentPlanId ?? "Free"}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_currentAdvertiser.activeAds} / 50 إعلان',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.go('/plans'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ترقية'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Cards
          const Text(
            'إحصائيات سريعة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'إجمالي المشاهدات',
                '1,247',
                Icons.visibility,
                Colors.blue,
              ),
              _buildStatCard(
                'إجمالي التواصل',
                '89',
                Icons.phone,
                Colors.green,
              ),
              _buildStatCard(
                'إعلانات نشطة',
                '${_currentAdvertiser.activeAds}',
                Icons.check_circle,
                Colors.orange,
              ),
              _buildStatCard(
                'معدل التحويل',
                '7.1%',
                Icons.trending_up,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickAction(
            'إضافة إعلان جديد',
            'انشر مطبخك الجديد الآن',
            Icons.add_circle_outline,
            () => context.go('/dashboard/new-ad'),
          ),
          _buildQuickAction(
            'إدارة الإعلانات',
            'عدل أو احذف إعلاناتك',
            Icons.edit,
            () {
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
          _buildQuickAction(
            'عرض الإحصائيات',
            'تابع أداء إعلاناتك',
            Icons.analytics,
            () {
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMyAds() {
    return FutureBuilder<List<KitchenAd>>(
      future: _repository.getByAdvertiser(_currentAdvertiser.id),
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
                const Text('حدث خطأ في تحميل الإعلانات'),
              ],
            ),
          );
        }

        final ads = snapshot.data ?? [];

        if (ads.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد إعلانات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'ابدأ بإضافة إعلانك الأول',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.go('/dashboard/new-ad'),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة إعلان'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ads.length,
          itemBuilder: (context, index) {
            final ad = ads[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ad.galleryImages.isNotEmpty
                      ? Image.network(
                          ad.galleryImages.first,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.kitchen),
                        ),
                ),
                title: Text(
                  ad.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${ad.viewCount} مشاهدة • ${ad.contactClickCount} تواصل'),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ad.status == KitchenAdStatus.active
                            ? Colors.green[100]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ad.status == KitchenAdStatus.active ? 'نشط' : 'غير نشط',
                        style: TextStyle(
                          fontSize: 12,
                          color: ad.status == KitchenAdStatus.active
                              ? Colors.green[700]
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('عرض'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        context.go('/kitchens/${ad.id}');
                        break;
                      case 'edit':
                        // TODO: Navigate to edit
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('قريباً: تعديل الإعلان')),
                        );
                        break;
                      case 'delete':
                        _showDeleteDialog(ad);
                        break;
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تحليلات الأداء',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Mock chart placeholder
          Card(
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'الرسوم البيانية قيد التطوير',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'إحصائيات مفصلة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildAnalyticsItem('إجمالي المشاهدات', '1,247', '+12%'),
          _buildAnalyticsItem('إجمالي التواصل', '89', '+8%'),
          _buildAnalyticsItem('معدل التحويل', '7.1%', '+2.1%'),
          _buildAnalyticsItem('متوسط زمن التصفح', '2:45 دقيقة', '+15s'),
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(String title, String value, String change) {
    final isPositive = change.startsWith('+');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPositive ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                change,
                style: TextStyle(
                  color: isPositive ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'الإعدادات',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingsSection(
          'الحساب',
          [
            _buildSettingsItem('معلومات الحساب', Icons.person, () {}),
            _buildSettingsItem('تغيير كلمة المرور', Icons.lock, () {}),
            _buildSettingsItem('الاشتراك والفواتير', Icons.receipt, () => context.go('/plans')),
          ],
        ),
        _buildSettingsSection(
          'التفضيلات',
          [
            _buildSettingsItem('الإشعارات', Icons.notifications, () {}),
            _buildSettingsItem('اللغة', Icons.language, () {}),
          ],
        ),
        _buildSettingsSection(
          'المساعدة',
          [
            _buildSettingsItem('مركز المساعدة', Icons.help, () {}),
            _buildSettingsItem('اتصل بنا', Icons.email, () => context.go('/contact')),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            // TODO: Logout
            context.go('/');
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Card(
          child: Column(children: items),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showDeleteDialog(KitchenAd ad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الإعلان'),
        content: Text('هل أنت متأكد من حذف "${ad.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              navigator.pop();
              await _repository.delete(ad.id);
              setState(() {}); // Refresh the list
              messenger.showSnackBar(
                const SnackBar(content: Text('تم حذف الإعلان')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
