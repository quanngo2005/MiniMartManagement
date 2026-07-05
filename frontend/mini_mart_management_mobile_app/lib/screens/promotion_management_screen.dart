import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/promotion.dart';
import 'package:mini_mart_management_mobile_app/providers/promotion_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/app_bottom_nav_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/promotions/promotion_rule_card.dart';

class PromotionManagementScreen extends StatefulWidget {
  const PromotionManagementScreen({this.showBottomNavBar = true, super.key});

  final bool showBottomNavBar;

  @override
  State<PromotionManagementScreen> createState() =>
      _PromotionManagementScreenState();
}

class _PromotionManagementScreenState extends State<PromotionManagementScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromotionProvider>().fetchPromotions();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToForm() {
    final target = _formKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Consumer<PromotionProvider>(
          builder: (context, provider, _) => SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildListSection(context, provider),
                const SizedBox(height: 40),
                KeyedSubtree(
                  key: _formKey,
                  child: _PromotionCreateForm(
                    onSave: (data) async {
                      final ok = await provider.createPromotion(data);
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tạo khuyến mãi thành công!'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(heroTag: null,
        onPressed: _scrollToForm,
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, size: 32),
      ),
      bottomNavigationBar: widget.showBottomNavBar
          ? const AppBottomNavBar(selectedTab: AppNavTab.promotions)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceContainerLowest,
      foregroundColor: AppColors.primary,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        color: AppColors.primary,
        onPressed: () {},
      ),
      title: Text(
        'Chương trình khuyến mãi',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          color: AppColors.primary,
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.borderGray, height: 1),
      ),
    );
  }

  Widget _buildListSection(BuildContext context, PromotionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Danh sách chương trình',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${provider.promotions.length} chương trình',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (provider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (provider.error != null)
          _buildErrorState(provider)
        else if (provider.promotions.isEmpty)
          _buildEmptyState()
        else
          ...provider.promotions.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PromotionRuleCard(
                promotion: p,
                onDelete: () => _confirmDelete(context, p),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState(PromotionProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.statusError, size: 36),
          const SizedBox(height: 8),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.statusError),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: provider.fetchPromotions,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: const Column(
        children: [
          Icon(Icons.local_offer_outlined, color: AppColors.textMuted, size: 32),
          SizedBox(height: 8),
          Text(
            'Chưa có chương trình nào.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Promotion p) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa khuyến mãi?'),
        content: Text('Bạn có chắc muốn xóa "${p.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.statusError),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<PromotionProvider>().deletePromotion(p.promotionId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _PromotionCreateForm extends StatefulWidget {
  const _PromotionCreateForm({required this.onSave});

  final Future<void> Function(Map<String, dynamic> data) onSave;

  @override
  State<_PromotionCreateForm> createState() => _PromotionCreateFormState();
}

class _PromotionCreateFormState extends State<_PromotionCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _discountCtrl = TextEditingController(text: '0.00');
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  int _discountType = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_moderator_outlined,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Tạo chương trình mới',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _fieldLabel('Tên chương trình'),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Giảm 10% cuối tuần...',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDiscountTypeDropdown()),
              ],
            ),
            const SizedBox(height: 16),
            _fieldLabel('Giá trị giảm'),
            TextFormField(
              controller: _discountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                suffixText: _discountType == 0 ? '%' : (_discountType == 1 ? 'đ' : ''),
                hintText: _discountType == 2 ? 'Không áp dụng' : null,
              ),
              enabled: _discountType != 2,
              validator: (v) {
                if (_discountType == 2) return null;
                if (v == null || v.isEmpty) return 'Bắt buộc';
                if (double.tryParse(v) == null) return 'Số không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    context,
                    'Ngày bắt đầu',
                    _startDate,
                    () => _pickDate(context, isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    context,
                    'Ngày kết thúc',
                    _endDate,
                    () => _pickDate(context, isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Lưu chương trình'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildDiscountTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Loại khuyến mãi'),
        DropdownButtonFormField<int>(
          value: _discountType,
          decoration: const InputDecoration(),
          items: const [
            DropdownMenuItem(value: 0, child: Text('Giảm theo % (PercentDiscount)')),
            DropdownMenuItem(value: 1, child: Text('Giảm tiền mặt (FixedAmount)')),
            DropdownMenuItem(value: 2, child: Text('Mua X Tặng Y (BuyXGetYFree)')),
          ],
          onChanged: (v) => setState(() => _discountType = v ?? 0),
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime date,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: const InputDecoration(
              suffixIcon: Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.outlineVariant,
              ),
            ),
            child: Text(DateFormat('dd/MM/yyyy').format(date)),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ngày kết thúc phải sau ngày bắt đầu.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final discount = double.tryParse(_discountCtrl.text) ?? 0;
    // type 0 = PercentDiscount, type 1 = BuyXGetYFree
    final promotionType = _discountType == 2 ? 1 : 0;

    await widget.onSave({
      'name': _nameCtrl.text.trim(),
      'description': '',
      'type': promotionType,
      'discountPercent': _discountType == 0 ? discount : null,
      'discountAmount': _discountType == 1 ? discount : null,
      'buyQuantity': _discountType == 2 ? 2 : null,
      'giftQuantity': _discountType == 2 ? 1 : null,
      'startDate': _startDate.toIso8601String(),
      'endDate': _endDate.toIso8601String(),
      'isActive': true,
      'productIds': <int>[],
    });

    if (mounted) {
      setState(() => _isSaving = false);
      _nameCtrl.clear();
      _discountCtrl.text = '0.00';
    }
  }
}
