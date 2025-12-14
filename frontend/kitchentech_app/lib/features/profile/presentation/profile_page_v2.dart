import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Spec 2.8: صفحة الملف الشخصي للمستخدم (User Profile)
/// إدارة البيانات الشخصية، المفضلة، والإعدادات
class ProfilePageV2 extends StatefulWidget {
  const ProfilePageV2({super.key});

  @override
  State<ProfilePageV2> createState() => _ProfilePageV2State();
}

class _ProfilePageV2State extends State<ProfilePageV2> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form keys
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _securityFormKey = GlobalKey<FormState>();

  // Personal Info Controllers
  final _nameController = TextEditingController(text: 'أحمد محمد علي');
  final _emailController = TextEditingController(text: 'ahmed.m@example.com');
  final _phoneController = TextEditingController(text: '0501234567');
  String _selectedCity = 'الرياض';

  // Security Controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // States
  bool _isEditingPersonalInfo = false;
  bool _isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Mock user stats
  final int _savedAdsCount = 8;
  final int _contactsCount = 15;
  final String _memberSince = 'يناير 2024';

  final List<String> _cities = [
    'الرياض',
    'جدة',
    'مكة المكرمة',
    'المدينة المنورة',
    'الدمام',
    'الخبر',
    'الظهران',
    'الطائف',
    'تبوك',
    'بريدة',
    'أبها',
    'خميس مشيط',
    'الأحساء',
    'القطيف',
    'حائل',
    'نجران',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: theme.colorScheme.primary,
                tabs: const [
                  Tab(text: 'المعلومات الشخصية'),
                  Tab(text: 'الأمان'),
                  Tab(text: 'الإعدادات'),
                ],
              ),
              Container(
                height: 1,
                color: Colors.grey[200],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Personal Info Tab
          _buildPersonalInfoTab(context, theme, isWide),
          // Security Tab
          _buildSecurityTab(context, theme, isWide),
          // Settings Tab
          _buildSettingsTab(context, theme, isWide),
        ],
      ),
    );
  }

  // ==================== Personal Info Tab ====================
  Widget _buildPersonalInfoTab(BuildContext context, ThemeData theme, bool isWide) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: EdgeInsets.all(isWide ? 32 : 16),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(theme),
                const SizedBox(height: 32),

                // User Stats
                _buildUserStats(theme),
                const SizedBox(height: 32),

                // Personal Information Form
                _buildPersonalInfoForm(theme),
                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
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
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'أ.م',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // TODO: Change avatar
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _emailController.text,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, size: 16, color: Colors.green[700]),
                const SizedBox(width: 6),
                Text(
                  'حساب موثق',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
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

  Widget _buildUserStats(ThemeData theme) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.favorite,
            count: '$_savedAdsCount',
            label: 'إعلان محفوظ',
            color: Colors.red,
            onTap: () => context.go('/favorites'),
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatItem(
            icon: Icons.phone,
            count: '$_contactsCount',
            label: 'تواصلت',
            color: Colors.blue,
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatItem(
            icon: Icons.calendar_today,
            count: _memberSince,
            label: 'عضو منذ',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm(ThemeData theme) {
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
      child: Form(
        key: _personalInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المعلومات الشخصية',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isEditingPersonalInfo)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEditingPersonalInfo = true;
                      });
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('تعديل'),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Full Name
            TextFormField(
              controller: _nameController,
              enabled: _isEditingPersonalInfo,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: !_isEditingPersonalInfo,
                fillColor: _isEditingPersonalInfo ? null : Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              enabled: _isEditingPersonalInfo,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: !_isEditingPersonalInfo,
                fillColor: _isEditingPersonalInfo ? null : Colors.grey[100],
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال البريد الإلكتروني';
                }
                if (!value.contains('@')) {
                  return 'البريد الإلكتروني غير صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              enabled: _isEditingPersonalInfo,
              decoration: InputDecoration(
                labelText: 'رقم الجوال',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: !_isEditingPersonalInfo,
                fillColor: _isEditingPersonalInfo ? null : Colors.grey[100],
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الجوال';
                }
                if (!value.startsWith('05') || value.length != 10) {
                  return 'رقم الجوال غير صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // City
            DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              decoration: InputDecoration(
                labelText: 'المدينة',
                prefixIcon: const Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: !_isEditingPersonalInfo,
                fillColor: _isEditingPersonalInfo ? null : Colors.grey[100],
              ),
              items: _cities.map((city) {
                return DropdownMenuItem(value: city, child: Text(city));
              }).toList(),
              onChanged: _isEditingPersonalInfo
                  ? (value) {
                      setState(() {
                        _selectedCity = value!;
                      });
                    }
                  : null,
            ),

            if (_isEditingPersonalInfo) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditingPersonalInfo = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _savePersonalInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('حفظ التغييرات'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildActionCard(
          icon: Icons.favorite,
          title: 'الإعلانات المحفوظة',
          subtitle: 'عرض $_savedAdsCount إعلان محفوظ',
          color: Colors.red,
          onTap: () => context.go('/favorites'),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.history,
          title: 'سجل التصفح',
          subtitle: 'الإعلانات التي شاهدتها مؤخراً',
          color: Colors.blue,
          onTap: () {
            // TODO: Navigate to browsing history
          },
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.notifications,
          title: 'الإشعارات',
          subtitle: 'إدارة إشعاراتك',
          color: Colors.orange,
          onTap: () {
            // TODO: Navigate to notifications
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // ==================== Security Tab ====================
  Widget _buildSecurityTab(BuildContext context, ThemeData theme, bool isWide) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: EdgeInsets.all(isWide ? 32 : 16),
            child: Column(
              children: [
                // Change Password
                _buildChangePasswordSection(theme),
                const SizedBox(height: 24),

                // Two-Factor Authentication
                _buildTwoFactorSection(theme),
                const SizedBox(height: 24),

                // Active Sessions
                _buildActiveSessionsSection(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChangePasswordSection(ThemeData theme) {
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
      child: Form(
        key: _securityFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تغيير كلمة المرور',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isChangingPassword)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isChangingPassword = true;
                      });
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('تغيير'),
                  ),
              ],
            ),
            if (_isChangingPassword) ...[
              const SizedBox(height: 24),
              // Current Password
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال كلمة المرور الحالية';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال كلمة المرور الجديدة';
                  }
                  if (value.length < 8) {
                    return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'كلمة المرور غير متطابقة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Password Strength Indicator
              _buildPasswordStrengthIndicator(),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isChangingPassword = false;
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('تغيير كلمة المرور'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
              Text(
                'آخر تغيير: 15 نوفمبر 2024',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _newPasswordController.text;
    final strength = _calculatePasswordStrength(password);
    final strengthText = ['ضعيفة', 'متوسطة', 'قوية', 'قوية جداً'];
    final strengthColor = [Colors.red, Colors.orange, Colors.green, Colors.green[700]!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: (strength + 1) / 4,
                backgroundColor: Colors.grey[200],
                color: strengthColor[strength],
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strengthText[strength],
              style: TextStyle(
                color: strengthColor[strength],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'يجب أن تحتوي كلمة المرور على:',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildPasswordRequirement('8 أحرف على الأقل', password.length >= 8),
        _buildPasswordRequirement(
          'حرف كبير',
          password.contains(RegExp(r'[A-Z]')),
        ),
        _buildPasswordRequirement(
          'حرف صغير',
          password.contains(RegExp(r'[a-z]')),
        ),
        _buildPasswordRequirement('رقم', password.contains(RegExp(r'[0-9]'))),
      ],
    );
  }

  Widget _buildPasswordRequirement(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: met ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: met ? Colors.green : Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength.clamp(0, 3);
  }

  Widget _buildTwoFactorSection(ThemeData theme) {
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
              Icon(Icons.security, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'المصادقة الثنائية',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Switch(
                value: false,
                onChanged: (value) {
                  // TODO: Enable 2FA
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'أضف طبقة حماية إضافية لحسابك باستخدام المصادقة الثنائية',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionsSection(ThemeData theme) {
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
          Text(
            'الجلسات النشطة',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSessionItem(
            device: 'Chrome - Windows',
            location: 'الرياض، السعودية',
            time: 'الآن',
            isCurrent: true,
          ),
          const Divider(height: 24),
          _buildSessionItem(
            device: 'Safari - iPhone',
            location: 'جدة، السعودية',
            time: 'منذ ساعتين',
            isCurrent: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem({
    required String device,
    required String location,
    required String time,
    required bool isCurrent,
  }) {
    return Row(
      children: [
        Icon(
          isCurrent ? Icons.devices : Icons.phone_iphone,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '$location • $time',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'الحالي',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          TextButton(
            onPressed: () {
              // TODO: Logout from this session
            },
            child: const Text('تسجيل خروج'),
          ),
      ],
    );
  }

  // ==================== Settings Tab ====================
  Widget _buildSettingsTab(BuildContext context, ThemeData theme, bool isWide) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: EdgeInsets.all(isWide ? 32 : 16),
            child: Column(
              children: [
                // Notifications Settings
                _buildNotificationSettings(theme),
                const SizedBox(height: 24),

                // Privacy Settings
                _buildPrivacySettings(theme),
                const SizedBox(height: 24),

                // Account Actions
                _buildAccountActions(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(ThemeData theme) {
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
          Text(
            'الإشعارات',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'إشعارات البريد الإلكتروني',
            'استلام تنبيهات عبر البريد',
            true,
          ),
          const Divider(height: 24),
          _buildSwitchTile(
            'إشعارات SMS',
            'استلام تنبيهات عبر الرسائل النصية',
            false,
          ),
          const Divider(height: 24),
          _buildSwitchTile(
            'إشعارات التطبيق',
            'استلام إشعارات داخل التطبيق',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings(ThemeData theme) {
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
          Text(
            'الخصوصية',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'إظهار البروفايل',
            'السماح للآخرين برؤية ملفك الشخصي',
            true,
          ),
          const Divider(height: 24),
          _buildSwitchTile(
            'إظهار رقم الجوال',
            'عرض رقم الجوال في الإعلانات',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (newValue) {
            // TODO: Update setting
          },
        ),
      ],
    );
  }

  Widget _buildAccountActions(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Hide Account
        _buildDangerActionCard(
          icon: Icons.visibility_off,
          title: 'إخفاء الحساب',
          subtitle: 'إخفاء حسابك مؤقتاً',
          color: Colors.orange,
          onTap: () {
            _showHideAccountDialog(context);
          },
        ),
        const SizedBox(height: 12),

        // Delete Account
        _buildDangerActionCard(
          icon: Icons.delete_forever,
          title: 'حذف الحساب',
          subtitle: 'حذف الحساب بشكل نهائي',
          color: Colors.red,
          onTap: () {
            _showDeleteAccountDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildDangerActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // ==================== Actions ====================
  void _savePersonalInfo() {
    if (_personalInfoFormKey.currentState!.validate()) {
      setState(() {
        _isEditingPersonalInfo = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ التغييرات بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _changePassword() {
    if (_securityFormKey.currentState!.validate()) {
      setState(() {
        _isChangingPassword = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تغيير كلمة المرور بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showHideAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إخفاء الحساب'),
        content: const Text(
          'هل أنت متأكد من إخفاء حسابك؟ سيتم إخفاء جميع معلوماتك مؤقتاً.',
          style: TextStyle(height: 1.5),
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
                  content: Text('تم إخفاء الحساب بنجاح'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('إخفاء'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('حذف الحساب'),
          ],
        ),
        content: const Text(
          'تحذير: حذف الحساب عملية نهائية ولا يمكن التراجع عنها.\n\nسيتم حذف جميع بياناتك وإعلاناتك بشكل دائم.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to delete confirmation page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف الحساب'),
          ),
        ],
      ),
    );
  }
}
