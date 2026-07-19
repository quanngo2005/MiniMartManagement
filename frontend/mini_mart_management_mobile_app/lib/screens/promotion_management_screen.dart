import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/promotion.dart';
import 'package:mini_mart_management_mobile_app/providers/product_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/promotion_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/screens/promotion_detail_screen.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/app_bottom_nav_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/promotions/promotion_rule_card.dart';

class PromotionManagementScreen extends StatefulWidget {
  const PromotionManagementScreen({
    this.showBottomNavBar = true,
    this.onMenuTap,
    super.key,
  });

  final bool showBottomNavBar;
  final VoidCallback? onMenuTap;

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
      context.read<ProductProvider>().fetchAll();
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
                      if (!context.mounted) return ok;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Tạo khuyến mãi thành công!'
                                : provider.error ?? 'Không thể tạo khuyến mãi.',
                          ),
                        ),
                      );

                      return ok;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
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
        onPressed: widget.onMenuTap ?? () {},
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
                onTap: () => _openDetail(context, p),
                onEdit: () => _openDetail(context, p),
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
          const Icon(
            Icons.error_outline,
            color: AppColors.statusError,
            size: 36,
          ),
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
          Icon(
            Icons.local_offer_outlined,
            color: AppColors.textMuted,
            size: 32,
          ),
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
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.statusError,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<PromotionProvider>().deletePromotion(
                p.promotionId,
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, Promotion promotion) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PromotionDetailScreen(promotionId: promotion.promotionId),
      ),
    );
  }
}

class _PromotionCreateForm extends StatefulWidget {
  const _PromotionCreateForm({required this.onSave});

  final Future<bool> Function(Map<String, dynamic> data) onSave;

  @override
  State<_PromotionCreateForm> createState() => _PromotionCreateFormState();
}

class _PromotionCreateFormState extends State<_PromotionCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _discountCtrl = TextEditingController(text: '10');
  final _minimumOrderCtrl = TextEditingController(text: '150000');
  final _buyQuantityCtrl = TextEditingController(text: '1');
  final _giftQuantityCtrl = TextEditingController(text: '1');
  final _productSearchCtrl = TextEditingController();
  final Set<int> _selectedDiscountProductIds = <int>{};
  int? _selectedMainProductId;
  int? _selectedGiftProductId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  int _promotionRule = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _discountCtrl.dispose();
    _minimumOrderCtrl.dispose();
    _buyQuantityCtrl.dispose();
    _giftQuantityCtrl.dispose();
    _productSearchCtrl.dispose();
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
                const Icon(
                  Icons.add_moderator_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
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
                hintText: 'Ví dụ: Hóa đơn từ 150K giảm 10K',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: 16),
            _buildPromotionRuleDropdown(),
            const SizedBox(height: 16),
            if (_promotionRule == 0) ...[
              _fieldLabel('Ngưỡng hóa đơn'),
              TextFormField(
                controller: _minimumOrderCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  suffixText: 'đ',
                  hintText: 'Ví dụ: 500000',
                ),
                validator: _validatePositiveNumber,
              ),
              const SizedBox(height: 16),
              _fieldLabel('Giá trị giảm'),
              TextFormField(
                controller: _discountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  suffixText: '%',
                  hintText: 'Ví dụ: 5',
                ),
                validator: _validatePercentage,
              ),
            ] else if (_promotionRule == 1) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildPositiveIntField(
                      label: 'Số lượng mua',
                      controller: _buyQuantityCtrl,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPositiveIntField(
                      label: 'Số lượng tặng',
                      controller: _giftQuantityCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSingleProductSelector(
                title: 'Sản phẩm chính',
                selectedProductId: _selectedMainProductId,
                onSelected: (productId) => setState(() {
                  _selectedMainProductId = productId;
                }),
              ),
              const SizedBox(height: 16),
              _buildSingleProductSelector(
                title: 'Sản phẩm tặng kèm',
                selectedProductId: _selectedGiftProductId,
                onSelected: (productId) => setState(() {
                  _selectedGiftProductId = productId;
                }),
              ),
            ] else if (_promotionRule == 2) ...[
              _fieldLabel('Giảm giá sản phẩm'),
              TextFormField(
                controller: _discountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  suffixText: '%',
                  hintText: 'Ví dụ: 10',
                ),
                validator: _validatePercentage,
              ),
              const SizedBox(height: 16),
              _buildMultiProductSelector(
                title: 'Sản phẩm áp dụng',
                selectedProductIds: _selectedDiscountProductIds,
              ),
            ],
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
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
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

  Widget _buildMultiProductSelector({
    required String title,
    required Set<int> selectedProductIds,
  }) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final keyword = _productSearchCtrl.text.trim().toLowerCase();
        final filteredProducts = provider.products.where((product) {
          if (keyword.isEmpty) return true;
          return product.productName.toLowerCase().contains(keyword) ||
              product.productCode.toLowerCase().contains(keyword) ||
              product.barcode.toLowerCase().contains(keyword);
        }).toList();

        final selectionHint = switch (_promotionRule) {
          2 => 'Chọn 1 hoặc nhiều sản phẩm để áp dụng giảm giá.',
          _ => '',
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _fieldLabel(title)),
                Text(
                  selectedProductIds.isEmpty
                      ? '0 đã chọn'
                      : '${selectedProductIds.length} đã chọn',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _productSearchCtrl,
              decoration: const InputDecoration(
                hintText: 'Tìm theo tên, mã hoặc barcode',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              selectionHint,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.error != null)
              Text(
                provider.error!,
                style: const TextStyle(color: AppColors.statusError),
              )
            else if (filteredProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Không tìm thấy sản phẩm.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filteredProducts.map((product) {
                  final selected = selectedProductIds.contains(
                    product.productId,
                  );
                  return FilterChip(
                    selected: selected,
                    label: Text(
                      '${product.productName} (${product.productCode})',
                      overflow: TextOverflow.ellipsis,
                    ),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          selectedProductIds.add(product.productId);
                        } else {
                          selectedProductIds.remove(product.productId);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSingleProductSelector({
    required String title,
    required int? selectedProductId,
    required ValueChanged<int?> onSelected,
  }) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final keyword = _productSearchCtrl.text.trim().toLowerCase();
        final filteredProducts = provider.products.where((product) {
          if (keyword.isEmpty) return true;
          return product.productName.toLowerCase().contains(keyword) ||
              product.productCode.toLowerCase().contains(keyword) ||
              product.barcode.toLowerCase().contains(keyword);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel(title),
            TextFormField(
              controller: _productSearchCtrl,
              decoration: const InputDecoration(
                hintText: 'Tìm theo tên, mã hoặc barcode',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.error != null)
              Text(
                provider.error!,
                style: const TextStyle(color: AppColors.statusError),
              )
            else if (filteredProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Không tìm thấy sản phẩm.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filteredProducts.map((product) {
                  final selected = selectedProductId == product.productId;
                  return FilterChip(
                    selected: selected,
                    label: Text(
                      '${product.productName} (${product.productCode})',
                      overflow: TextOverflow.ellipsis,
                    ),
                    onSelected: (value) {
                      onSelected(value ? product.productId : null);
                    },
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPromotionRuleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Loại khuyến mãi'),
        DropdownButtonFormField<int>(
          initialValue: _promotionRule,
          decoration: const InputDecoration(),
          items: const [
            DropdownMenuItem(value: 0, child: Text('Giảm giá ngưỡng hóa đơn')),
            DropdownMenuItem(value: 1, child: Text('Mua X tặng Y')),
            DropdownMenuItem(value: 2, child: Text('Giảm giá sản phẩm')),
          ],
          onChanged: (v) => setState(() => _promotionRule = v ?? 0),
        ),
      ],
    );
  }

  Widget _buildPositiveIntField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Ví dụ: 1'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Bắt buộc';
            final value = int.tryParse(v.trim());
            if (value == null || value <= 0) {
              return 'Số nguyên phải lớn hơn 0';
            }
            return null;
          },
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
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 1));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_endDate.isAfter(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ngày kết thúc phải sau ngày bắt đầu.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final discount = double.tryParse(_discountCtrl.text.trim()) ?? 0;
    final minimumOrder = double.tryParse(_minimumOrderCtrl.text.trim()) ?? 0;
    final buyQuantity = int.tryParse(_buyQuantityCtrl.text.trim()) ?? 0;
    final giftQuantity = int.tryParse(_giftQuantityCtrl.text.trim()) ?? 0;
    final promotionType = _promotionRule;

    if (_promotionRule == 1 &&
        (_selectedMainProductId == null || _selectedGiftProductId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn sản phẩm chính và sản phẩm tặng kèm.'),
        ),
      );
      setState(() => _isSaving = false);
      return;
    }

    if (_promotionRule == 2 && _selectedDiscountProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 sản phẩm áp dụng.'),
        ),
      );
      setState(() => _isSaving = false);
      return;
    }

    try {
      final ok = await widget.onSave({
        'name': _nameCtrl.text.trim(),
        'description': _buildDescription(),
        'type': promotionType,
        'discountPercent': (_promotionRule == 0 || _promotionRule == 2)
            ? discount
            : null,
        'discountAmount': null,
        'minimumOrderAmount': _promotionRule == 0 ? minimumOrder : null,
        'buyQuantity': _promotionRule == 1 ? buyQuantity : null,
        'giftQuantity': _promotionRule == 1 ? giftQuantity : null,
        'giftProductId': _promotionRule == 1 ? _selectedGiftProductId : null,
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'isActive': true,
        'productIds': _promotionRule == 1
            ? <int>[_selectedMainProductId!]
            : _selectedDiscountProductIds.toList(),
      });

      if (ok && mounted) {
        _resetForm();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _validatePositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bắt buộc';
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return 'Số phải lớn hơn 0';
    return null;
  }

  String? _validatePercentage(String? value) {
    final error = _validatePositiveNumber(value);
    if (error != null) return error;
    final parsed = double.parse(value!.trim());
    if (parsed > 100) return 'Phần trăm không được vượt 100';
    return null;
  }

  String _buildDescription() {
    if (_promotionRule == 0) {
      return 'Ngưỡng hóa đơn ${_minimumOrderCtrl.text.trim()}đ giảm ${_discountCtrl.text.trim()}%';
    }

    if (_promotionRule == 1) {
      return 'Mua ${_buyQuantityCtrl.text.trim()} tặng ${_giftQuantityCtrl.text.trim()}';
    }

    return 'Giảm ${_discountCtrl.text.trim()}% cho sản phẩm được chọn';
  }

  void _resetForm() {
    setState(() {
      _nameCtrl.clear();
      _discountCtrl.text = '10';
      _minimumOrderCtrl.text = '150000';
      _buyQuantityCtrl.text = '1';
      _giftQuantityCtrl.text = '1';
      _productSearchCtrl.clear();
      _selectedDiscountProductIds.clear();
      _selectedMainProductId = null;
      _selectedGiftProductId = null;
      _promotionRule = 0;
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 30));
    });
  }
}
