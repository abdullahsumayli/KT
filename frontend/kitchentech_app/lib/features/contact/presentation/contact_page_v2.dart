import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Spec 2.10: صفحة تواصل معنا (Contact Page)
/// نموذج اتصال + معلومات التواصل (بريد - واتساب - سوشيال ميديا)
class ContactPageV2 extends StatefulWidget {
  const ContactPageV2({super.key});

  @override
  State<ContactPageV2> createState() => _ContactPageV2State();
}

class _ContactPageV2State extends State<ContactPageV2> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedMessageType = 'اقتراح';
  bool _isSubmitting = false;

  final List<String> _messageTypes = [
    'اقتراح',
    'مشكلة',
    'شراكة',
    'إعلان',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✓ تم إرسال رسالتك بنجاح. سنتواصل معك قريباً'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // Clear form
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
    setState(() => _selectedMessageType = 'اقتراح');
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح الرابط')),
      );
    }
  }

  Future<void> _sendEmail(String email) async {
    await _launchUrl('mailto:$email');
  }

  Future<void> _sendWhatsApp(String phone) async {
    // Remove any spaces or special characters from phone number
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    await _launchUrl('https://wa.me/$cleanPhone');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('تواصل معنا'),
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(theme, isWide),

            // Main Content
            Padding(
              padding: EdgeInsets.all(isWide ? 60 : 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Contact Form (60%)
                            Expanded(
                              flex: 6,
                              child: _buildContactForm(theme, isWide),
                            ),
                            const SizedBox(width: 40),
                            // Contact Info (40%)
                            Expanded(
                              flex: 4,
                              child: _buildContactInfo(theme, isWide),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildContactForm(theme, isWide),
                            const SizedBox(height: 32),
                            _buildContactInfo(theme, isWide),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme, bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isWide ? 60 : 40,
        horizontal: isWide ? 60 : 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.headset_mic,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'نحن هنا لمساعدتك',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'تواصل معنا في أي وقت، فريقنا جاهز للإجابة على استفساراتك',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactForm(ThemeData theme, bool isWide) {
    return Container(
      padding: EdgeInsets.all(isWide ? 40 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.edit_note,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'أرسل لنا رسالة',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Name Field
            _buildTextFormField(
              controller: _nameController,
              label: 'الاسم',
              hint: 'أدخل اسمك الكامل',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال الاسم';
                }
                if (value.trim().length < 3) {
                  return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Email Field
            _buildTextFormField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              hint: 'example@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال البريد الإلكتروني';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'البريد الإلكتروني غير صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Message Type Dropdown
            _buildDropdownField(
              label: 'نوع الرسالة',
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 20),

            // Message Field
            _buildTextFormField(
              controller: _messageController,
              label: 'نص الرسالة',
              hint: 'اكتب رسالتك هنا...',
              icon: Icons.message_outlined,
              maxLines: 6,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء كتابة رسالتك';
                }
                if (value.trim().length < 10) {
                  return 'الرسالة يجب أن تكون 10 أحرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'إرسال الرسالة',
                            style: TextStyle(
                              fontSize: 16,
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
    );
  }

  Widget _buildContactInfo(ThemeData theme, bool isWide) {
    return Column(
      children: [
        // Contact Methods Card
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.contact_phone,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'معلومات التواصل',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Support Email
              _buildContactMethod(
                icon: Icons.email,
                title: 'البريد الإلكتروني',
                value: 'support@kitchentech.sa',
                color: Colors.blue,
                onTap: () => _sendEmail('support@kitchentech.sa'),
              ),
              const SizedBox(height: 16),

              // WhatsApp
              _buildContactMethod(
                icon: Icons.phone,
                title: 'واتساب',
                value: '+966 50 123 4567',
                color: Colors.green,
                onTap: () => _sendWhatsApp('+966501234567'),
              ),
              const SizedBox(height: 24),

              // Social Media Section
              const Divider(),
              const SizedBox(height: 24),

              const Text(
                'تابعنا على',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Social Media Buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildSocialButton(
                    icon: Icons.language,
                    label: 'تويتر X',
                    color: Colors.black,
                    onTap: () => _launchUrl('https://twitter.com/kitchentech_sa'),
                  ),
                  _buildSocialButton(
                    icon: Icons.facebook,
                    label: 'فيسبوك',
                    color: const Color(0xFF1877F2),
                    onTap: () => _launchUrl('https://facebook.com/kitchentech.sa'),
                  ),
                  _buildSocialButton(
                    icon: Icons.camera_alt,
                    label: 'إنستغرام',
                    color: const Color(0xFFE4405F),
                    onTap: () => _launchUrl('https://instagram.com/kitchentech.sa'),
                  ),
                  _buildSocialButton(
                    icon: Icons.play_arrow,
                    label: 'تيك توك',
                    color: Colors.black,
                    onTap: () => _launchUrl('https://tiktok.com/@kitchentech.sa'),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Working Hours Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                Colors.blue[50]!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.access_time,
                color: theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 12),
              const Text(
                'أوقات العمل',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'السبت - الخميس',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              Text(
                '9:00 صباحاً - 6:00 مساءً',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedMessageType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: _messageTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedMessageType = value);
        }
      },
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String value,
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
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
