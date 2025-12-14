import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/admin_service.dart';

/// صفحة تفاصيل وتحديث الطلب
class QuoteDetailsPage extends StatefulWidget {
  final int quoteId;

  const QuoteDetailsPage({super.key, required this.quoteId});

  @override
  State<QuoteDetailsPage> createState() => _QuoteDetailsPageState();
}

class _QuoteDetailsPageState extends State<QuoteDetailsPage> {
  Map<String, dynamic>? _quote;
  bool _isLoading = true;
  bool _isUpdating = false;

  final _notesController = TextEditingController();
  String? _selectedStatus;

  final List<Map<String, String>> _statusOptions = [
    {'id': 'new', 'label': 'جديد', 'icon': '🆕'},
    {'id': 'contacted', 'label': 'تم التواصل', 'icon': '📞'},
    {'id': 'quoted', 'label': 'تم إرسال السعر', 'icon': '💰'},
    {'id': 'converted', 'label': 'تم التحويل', 'icon': '✅'},
    {'id': 'lost', 'label': 'مفقود', 'icon': '❌'},
  ];

  @override
  void initState() {
    super.initState();
    _loadQuoteDetails();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadQuoteDetails() async {
    setState(() => _isLoading = true);

    try {
      final quote = await AdminService.fetchQuoteById(widget.quoteId);

      if (mounted) {
        setState(() {
          _quote = quote;
          _selectedStatus = quote['status'];
          _notesController.text = quote['admin_notes'] ?? '';
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

  Future<void> _updateQuote() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الحالة'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      await AdminService.updateQuoteStatus(
        id: widget.quoteId,
        status: _selectedStatus!,
        adminNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم تحديث الطلب بنجاح'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ خطأ: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteQuote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد من حذف هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    try {
      await AdminService.deleteQuote(widget.quoteId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم حذف الطلب'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ خطأ: $e'), backgroundColor: Colors.red));
      }
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

  String _getStyleLabel(String style) {
    switch (style) {
      case 'modern':
        return 'مودرن';
      case 'classic':
        return 'كلاسيك';
      case 'wood':
        return 'خشب طبيعي';
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
          title: Text(
            'طلب رقم #${widget.quoteId}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          actions: [
            if (!_isLoading && _quote != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _deleteQuote,
                tooltip: 'حذف الطلب',
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _quote == null
            ? const Center(child: Text('لم يتم العثور على الطلب'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Customer Info Card
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.teal.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'معلومات العميل',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildInfoRow('رقم الجوال', _quote!['phone'], Icons.phone),
                            _buildInfoRow(
                              'نوع المطبخ',
                              _getStyleLabel(_quote!['style']),
                              Icons.kitchen,
                            ),
                            _buildInfoRow('المدينة', _quote!['city'] ?? '-', Icons.location_on),
                            _buildInfoRow(
                              'تاريخ الطلب',
                              _formatDate(_quote!['created_at']),
                              Icons.calendar_today,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status Update Card
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.update, color: Colors.teal.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'تحديث الحالة',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'الحالة الحالية:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _statusOptions.map((status) {
                                final isSelected = _selectedStatus == status['id'];
                                return ChoiceChip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(status['icon']!),
                                      const SizedBox(width: 4),
                                      Text(status['label']!),
                                    ],
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedStatus = status['id'];
                                    });
                                  },
                                  selectedColor: _getStatusColor(status['id']!).withOpacity(0.2),
                                  checkmarkColor: _getStatusColor(status['id']!),
                                  side: BorderSide(
                                    color: isSelected
                                        ? _getStatusColor(status['id']!)
                                        : Colors.grey.shade300,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Admin Notes Card
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.notes, color: Colors.teal.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'ملاحظات إدارية',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _notesController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'أضف ملاحظات داخلية...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _quote!['phone']));
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(const SnackBar(content: Text('تم نسخ رقم الجوال')));
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('نسخ الرقم'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _isUpdating ? null : _updateQuote,
                            icon: _isUpdating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: const Text('حفظ التغييرات'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
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
