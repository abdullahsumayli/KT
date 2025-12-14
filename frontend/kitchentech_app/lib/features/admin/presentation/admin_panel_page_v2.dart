import 'package:flutter/material.dart';

/// Spec 2.11: لوحة تحكم المدير (Admin Panel)
/// إدارة المستخدمين، الإعلانات، الباقات، والإعدادات العامة
class AdminPanelPageV2 extends StatefulWidget {
  const AdminPanelPageV2({super.key});

  @override
  State<AdminPanelPageV2> createState() => _AdminPanelPageV2State();
}

class _AdminPanelPageV2State extends State<AdminPanelPageV2> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _sections = [
    {'icon': Icons.dashboard, 'title': 'لوحة التحكم', 'badge': null},
    {'icon': Icons.people, 'title': 'المستخدمون', 'badge': null},
    {'icon': Icons.kitchen, 'title': 'الإعلانات', 'badge': 5},
    {'icon': Icons.payment, 'title': 'الباقات والمدفوعات', 'badge': null},
    {'icon': Icons.settings, 'title': 'الإعدادات', 'badge': null},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('لوحة تحكم المدير'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
        actions: [
          // Notifications
          IconButton(
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_outlined),
            ),
            onPressed: () {},
            tooltip: 'الإشعارات',
          ),
          const SizedBox(width: 8),
          // Admin Profile
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المدير',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'admin@kitchentech.sa',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar (desktop only)
          if (isWide) _buildSidebar(theme),

          // Main Content
          Expanded(
            child: _buildMainContent(theme, isWide),
          ),
        ],
      ),
      // Bottom Nav (mobile only)
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: _sections.map((section) {
                return NavigationDestination(
                  icon: section['badge'] != null
                      ? Badge(
                          label: Text('${section['badge']}'),
                          child: Icon(section['icon']),
                        )
                      : Icon(section['icon']),
                  label: section['title'],
                );
              }).toList(),
            ),
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.kitchen, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                const Text(
                  'كيتشن تك',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                final section = _sections[index];
                final isSelected = _selectedIndex == index;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      section['icon'],
                      color: isSelected ? theme.colorScheme.primary : Colors.grey[600],
                    ),
                    title: Text(
                      section['title'],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? theme.colorScheme.primary : Colors.black87,
                      ),
                    ),
                    trailing: section['badge'] != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${section['badge']}',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          )
                        : null,
                    onTap: () {
                      setState(() => _selectedIndex = index);
                    },
                  ),
                );
              },
            ),
          ),

          // Logout
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, bool isWide) {
    switch (_selectedIndex) {
      case 0:
        return _DashboardSection();
      case 1:
        return _UsersSection();
      case 2:
        return _AdsSection();
      case 3:
        return _PlansSection();
      case 4:
        return _SettingsSection();
      default:
        return _DashboardSection();
    }
  }
}

// ============================================================================
// Dashboard Section
// ============================================================================
class _DashboardSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 1000;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'نظرة عامة',
            style: theme.textTheme.headlineMedium?.copyWith(
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
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isWide ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isWide ? 1.5 : 1.2,
            children: [
              _buildStatCard(
                icon: Icons.people,
                title: 'إجمالي المستخدمين',
                value: '1,234',
                change: '+12%',
                color: Colors.blue,
              ),
              _buildStatCard(
                icon: Icons.kitchen,
                title: 'الإعلانات النشطة',
                value: '856',
                change: '+8%',
                color: Colors.green,
              ),
              _buildStatCard(
                icon: Icons.pending,
                title: 'بانتظار المراجعة',
                value: '5',
                change: '-20%',
                color: Colors.orange,
              ),
              _buildStatCard(
                icon: Icons.attach_money,
                title: 'الإيرادات الشهرية',
                value: '45,000 ر.س',
                change: '+15%',
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Recent Activity
          _buildSectionHeader('آخر النشاطات', Icons.history),
          const SizedBox(height: 16),
          _buildActivityList(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String change,
    required Color color,
  }) {
    final isPositive = change.startsWith('+');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {
        'icon': Icons.person_add,
        'text': 'مستخدم جديد: أحمد محمد',
        'time': 'قبل 5 دقائق',
        'color': Colors.green
      },
      {
        'icon': Icons.kitchen,
        'text': 'إعلان جديد: مطبخ عصري',
        'time': 'قبل 15 دقيقة',
        'color': Colors.blue
      },
      {
        'icon': Icons.check_circle,
        'text': 'تم الموافقة على إعلان',
        'time': 'قبل ساعة',
        'color': Colors.green
      },
      {
        'icon': Icons.payment,
        'text': 'اشتراك جديد: باقة الذهبية',
        'time': 'قبل ساعتين',
        'color': Colors.orange
      },
      {'icon': Icons.block, 'text': 'تم حظر مستخدم', 'time': 'قبل 3 ساعات', 'color': Colors.red},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (activity['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  Icon(activity['icon'] as IconData, color: activity['color'] as Color, size: 20),
            ),
            title: Text(activity['text'] as String),
            subtitle: Text(activity['time'] as String),
          );
        },
      ),
    );
  }
}

// ============================================================================
// Users Section
// ============================================================================
class _UsersSection extends StatefulWidget {
  @override
  State<_UsersSection> createState() => _UsersSectionState();
}

class _UsersSectionState extends State<_UsersSection> {
  String _selectedUserType = 'الكل';
  final List<String> _userTypes = ['الكل', 'عملاء', 'معلنين'];

  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'أحمد محمد',
      'email': 'ahmed@example.com',
      'type': 'معلن',
      'status': 'نشط',
      'joinDate': '2025-01-15',
      'ads': 12,
    },
    {
      'id': '2',
      'name': 'سارة علي',
      'email': 'sara@example.com',
      'type': 'عميل',
      'status': 'نشط',
      'joinDate': '2025-02-20',
      'ads': 0,
    },
    {
      'id': '3',
      'name': 'محمد خالد',
      'email': 'mohamed@example.com',
      'type': 'معلن',
      'status': 'محظور',
      'joinDate': '2024-11-10',
      'ads': 5,
    },
    {
      'id': '4',
      'name': 'فاطمة حسن',
      'email': 'fatima@example.com',
      'type': 'عميل',
      'status': 'موقوف',
      'joinDate': '2025-03-01',
      'ads': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 1000;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إدارة المستخدمين',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'إجمالي ${_users.length} مستخدم',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add),
                label: const Text('إضافة مستخدم'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          Row(
            children: [
              // User Type Filter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedUserType,
                      isExpanded: true,
                      items: _userTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedUserType = value!);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Search
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'البحث عن مستخدم...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Users Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isWide ? _buildUsersTable() : _buildUsersCards(),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
        columns: const [
          DataColumn(label: Text('المستخدم', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('النوع', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('تاريخ الانضمام', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('الإعلانات', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: _users.map((user) {
          return DataRow(
            cells: [
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(user['name'][0]),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(user['email'],
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: user['type'] == 'معلن' ? Colors.orange[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(user['type'], style: const TextStyle(fontSize: 12)),
                ),
              ),
              DataCell(_buildStatusBadge(user['status'])),
              DataCell(Text(user['joinDate'])),
              DataCell(Text('${user['ads']}')),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditUserDialog(user),
                      tooltip: 'تعديل',
                    ),
                    IconButton(
                      icon: Icon(
                        user['status'] == 'محظور' ? Icons.check_circle : Icons.block,
                        size: 20,
                        color: user['status'] == 'محظور' ? Colors.green : Colors.red,
                      ),
                      onPressed: () => _toggleUserStatus(user),
                      tooltip: user['status'] == 'محظور' ? 'تفعيل' : 'حظر',
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUsersCards() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Text(user['name'][0]),
          ),
          title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user['email']),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user['type'] == 'معلن' ? Colors.orange[100] : Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(user['type'], style: const TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(user['status']),
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('تعديل')),
              const PopupMenuItem(value: 'toggle', child: Text('تغيير الحالة')),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _showEditUserDialog(user);
              } else if (value == 'toggle') {
                _toggleUserStatus(user);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    if (status == 'نشط') {
      color = Colors.green;
    } else if (status == 'موقوف') {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child:
          Text(status, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل بيانات المستخدم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'الاسم'),
              controller: TextEditingController(text: user['name']),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
              controller: TextEditingController(text: user['email']),
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
                const SnackBar(content: Text('✓ تم تحديث البيانات بنجاح')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    final newStatus = user['status'] == 'محظور' ? 'نشط' : 'محظور';
    setState(() {
      user['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✓ تم ${newStatus == "محظور" ? "حظر" : "تفعيل"} المستخدم')),
    );
  }
}

// ============================================================================
// Ads Section
// ============================================================================
class _AdsSection extends StatefulWidget {
  @override
  State<_AdsSection> createState() => _AdsSectionState();
}

class _AdsSectionState extends State<_AdsSection> {
  String _selectedStatus = 'الكل';
  final List<String> _statuses = ['الكل', 'بانتظار المراجعة', 'معتمدة', 'مرفوضة'];

  final List<Map<String, dynamic>> _ads = [
    {
      'id': '1',
      'title': 'مطبخ عصري بتصميم إيطالي',
      'advertiser': 'شركة المطابخ الذهبية',
      'status': 'بانتظار المراجعة',
      'date': '2025-12-10',
      'price': '45,000 ر.س',
      'featured': false,
    },
    {
      'id': '2',
      'title': 'مطبخ كلاسيكي فاخر',
      'advertiser': 'مطابخ الفخامة',
      'status': 'معتمدة',
      'date': '2025-12-09',
      'price': '38,000 ر.س',
      'featured': true,
    },
    {
      'id': '3',
      'title': 'مطبخ مودرن صغير',
      'advertiser': 'مطابخ العصر',
      'status': 'معتمدة',
      'date': '2025-12-08',
      'price': '25,000 ر.س',
      'featured': false,
    },
    {
      'id': '4',
      'title': 'مطبخ أمريكي مفتوح',
      'advertiser': 'شركة النجوم',
      'status': 'مرفوضة',
      'date': '2025-12-07',
      'price': '52,000 ر.س',
      'featured': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 1000;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'إدارة الإعلانات',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'إجمالي ${_ads.length} إعلان',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Status Filter
          Wrap(
            spacing: 12,
            children: _statuses.map((status) {
              final isSelected = _selectedStatus == status;
              return FilterChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedStatus = status);
                },
                backgroundColor: Colors.white,
                selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                side: BorderSide(
                  color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Ads List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ads.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final ad = _ads[index];
              return _buildAdCard(ad, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard(Map<String, dynamic> ad, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: ad['featured'] ? Border.all(color: Colors.amber, width: 2) : null,
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
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            ad['title'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (ad['featured']) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ad['advertiser'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              _buildAdStatusBadge(ad['status']),
            ],
          ),
          const SizedBox(height: 16),

          // Details
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(ad['date'], style: TextStyle(color: Colors.grey[600])),
              const SizedBox(width: 24),
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(ad['price'], style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 16),

          // Actions
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAdDetailsDialog(ad),
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('عرض التفاصيل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue[700],
                  elevation: 0,
                ),
              ),
              if (ad['status'] == 'بانتظار المراجعة') ...[
                ElevatedButton.icon(
                  onPressed: () => _approveAd(ad),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('موافقة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[50],
                    foregroundColor: Colors.green[700],
                    elevation: 0,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _rejectAd(ad),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('رفض'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[700],
                    elevation: 0,
                  ),
                ),
              ],
              if (ad['status'] == 'معتمدة')
                ElevatedButton.icon(
                  onPressed: () => _toggleFeatured(ad),
                  icon: Icon(ad['featured'] ? Icons.star : Icons.star_border, size: 18),
                  label: Text(ad['featured'] ? 'إلغاء التمييز' : 'تمييز'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[50],
                    foregroundColor: Colors.amber[700],
                    elevation: 0,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdStatusBadge(String status) {
    Color color;
    if (status == 'معتمدة') {
      color = Colors.green;
    } else if (status == 'بانتظار المراجعة') {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child:
          Text(status, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
    );
  }

  void _showAdDetailsDialog(Map<String, dynamic> ad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ad['title']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('المعلن', ad['advertiser']),
              _buildDetailRow('السعر', ad['price']),
              _buildDetailRow('التاريخ', ad['date']),
              _buildDetailRow('الحالة', ad['status']),
              const SizedBox(height: 16),
              const Text('الوصف:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('مطبخ فاخر بمواصفات عالية الجودة، مصنوع من أفضل المواد...'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _approveAd(Map<String, dynamic> ad) {
    setState(() {
      ad['status'] = 'معتمدة';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✓ تمت الموافقة على الإعلان')),
    );
  }

  void _rejectAd(Map<String, dynamic> ad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الإعلان'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'سبب الرفض',
            hintText: 'أدخل سبب رفض الإعلان...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                ad['status'] = 'مرفوضة';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ تم رفض الإعلان')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('رفض'),
          ),
        ],
      ),
    );
  }

  void _toggleFeatured(Map<String, dynamic> ad) {
    setState(() {
      ad['featured'] = !ad['featured'];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ad['featured'] ? '✓ تم تمييز الإعلان' : '✓ تم إلغاء تمييز الإعلان')),
    );
  }
}

// ============================================================================
// Plans Section
// ============================================================================
class _PlansSection extends StatelessWidget {
  final List<Map<String, dynamic>> _subscriptions = [
    {
      'id': '1',
      'advertiser': 'شركة المطابخ الذهبية',
      'plan': 'الباقة الذهبية',
      'price': '999 ر.س',
      'status': 'نشط',
      'startDate': '2025-12-01',
      'endDate': '2026-01-01',
      'paymentStatus': 'مدفوع',
    },
    {
      'id': '2',
      'advertiser': 'مطابخ الفخامة',
      'plan': 'الباقة الفضية',
      'price': '499 ر.س',
      'status': 'نشط',
      'startDate': '2025-11-15',
      'endDate': '2025-12-15',
      'paymentStatus': 'مدفوع',
    },
    {
      'id': '3',
      'advertiser': 'مطابخ العصر',
      'plan': 'الباقة البرونزية',
      'price': '199 ر.س',
      'status': 'منتهي',
      'startDate': '2025-10-01',
      'endDate': '2025-11-01',
      'paymentStatus': 'مدفوع',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 1000;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'الباقات والمدفوعات',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Plans Pricing Cards
          Text(
            'أسعار الباقات',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isWide ? 3 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isWide ? 1 : 2,
            children: [
              _buildPlanCard('البرونزية', '199 ر.س', '10 إعلانات', Colors.brown),
              _buildPlanCard('الفضية', '499 ر.س', '30 إعلان', Colors.grey),
              _buildPlanCard('الذهبية', '999 ر.س', 'إعلانات غير محدودة', Colors.amber),
            ],
          ),
          const SizedBox(height: 32),

          // Subscriptions
          Text(
            'الاشتراكات النشطة',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _subscriptions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final sub = _subscriptions[index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title:
                      Text(sub['advertiser'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${sub['plan']} - ${sub['price']}'),
                      Text('من ${sub['startDate']} إلى ${sub['endDate']}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPaymentBadge(sub['paymentStatus']),
                      const SizedBox(height: 4),
                      _buildStatusBadge(sub['status']),
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

  Widget _buildPlanCard(String name, String price, String limit, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.workspace_premium, color: color, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 8),
          Text(limit, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color),
              foregroundColor: color,
            ),
            child: const Text('تعديل السعر'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status, style: const TextStyle(fontSize: 11, color: Colors.green)),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = status == 'نشط' ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status, style: TextStyle(fontSize: 11, color: color)),
    );
  }
}

// ============================================================================
// Settings Section
// ============================================================================
class _SettingsSection extends StatefulWidget {
  @override
  State<_SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<_SettingsSection> {
  final _siteNameController = TextEditingController(text: 'كيتشن تك');
  final _supportEmailController = TextEditingController(text: 'support@kitchentech.sa');
  final _termsController = TextEditingController(text: 'نص الشروط والأحكام...');
  final _privacyController = TextEditingController(text: 'نص سياسة الخصوصية...');

  @override
  void dispose() {
    _siteNameController.dispose();
    _supportEmailController.dispose();
    _termsController.dispose();
    _privacyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 1000;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'الإعدادات العامة',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Site Settings
          _buildSettingsCard(
            title: 'إعدادات الموقع',
            icon: Icons.settings,
            children: [
              TextField(
                controller: _siteNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الموقع',
                  prefixIcon: Icon(Icons.web),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _supportEmailController,
                decoration: const InputDecoration(
                  labelText: 'بريد الدعم',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('الألوان الأساسية'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildColorBox(Colors.blue),
                    const SizedBox(width: 8),
                    _buildColorBox(Colors.orange),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {},
                      child: const Text('تعديل'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('شعار الموقع'),
                trailing: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload),
                  label: const Text('رفع شعار'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Terms & Privacy
          _buildSettingsCard(
            title: 'النصوص الثابتة',
            icon: Icons.description,
            children: [
              TextField(
                controller: _termsController,
                decoration: const InputDecoration(
                  labelText: 'الشروط والأحكام',
                  prefixIcon: Icon(Icons.gavel),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _privacyController,
                decoration: const InputDecoration(
                  labelText: 'سياسة الخصوصية',
                  prefixIcon: Icon(Icons.privacy_tip),
                ),
                maxLines: 5,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ تم حفظ الإعدادات بنجاح')),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('حفظ الإعدادات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildColorBox(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
    );
  }
}
