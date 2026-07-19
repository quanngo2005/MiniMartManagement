import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/product.dart';
import 'package:mini_mart_management_mobile_app/models/promotion.dart';
import 'package:mini_mart_management_mobile_app/providers/product_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/promotion_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/promotions/promotion_rule_card.dart';

class PromotionDetailScreen extends StatelessWidget {
  const PromotionDetailScreen({super.key, required this.promotionId});

  final int promotionId;

  @override
  Widget build(BuildContext context) {
    final promotion = context.select<PromotionProvider, Promotion?>((provider) {
      try {
        return provider.promotions.firstWhere(
          (item) => item.promotionId == promotionId,
        );
      } catch (_) {
        return null;
      }
    });

    final products = context.watch<ProductProvider>().products;
    final productById = {
      for (final product in products) product.productId: product,
    };

    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: const Text('Chi tiết khuyến mãi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: promotion == null
                ? null
                : () => _openEditSheet(context, promotion),
          ),
        ],
      ),
      body: promotion == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PromotionRuleCard(
                    promotion: promotion,
                    onTap: () {},
                    onEdit: () => _openEditSheet(context, promotion),
                    onDelete: () {},
                    showActionButtons: false,
                  ),
                  const SizedBox(height: 16),
                  _InfoSection(
                    title: 'Thông tin chung',
                    children: [
                      _InfoRow(label: 'Tên', value: promotion.name),
                      _InfoRow(label: 'Mô tả', value: promotion.description),
                      _InfoRow(
                        label: 'Thời gian',
                        value:
                            '${DateFormat('dd/MM/yyyy').format(promotion.startDate)} → ${DateFormat('dd/MM/yyyy').format(promotion.endDate)}',
                      ),
                      _InfoRow(label: 'Trạng thái', value: promotion.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoSection(
                    title: 'Thiết lập theo loại',
                    children: _buildRuleDetailRows(promotion, productById),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _openEditSheet(context, promotion),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Sửa thông tin'),
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildRuleDetailRows(
    Promotion promotion,
    Map<int, Product> productById,
  ) {
    if (promotion.type == 0) {
      return [
        _InfoRow(
          label: 'Ngưỡng hóa đơn',
          value: promotion.minimumOrderAmount == null
              ? '-'
              : '${NumberFormat('#,###').format(promotion.minimumOrderAmount)}đ',
        ),
        _InfoRow(
          label: 'Giảm',
          value: '${promotion.discountPercent?.toStringAsFixed(0) ?? '0'}%',
        ),
      ];
    }

    if (promotion.type == 1) {
      final mainProduct = promotion.productIds.isNotEmpty
          ? productById[promotion.productIds.first]
          : null;
      final giftProduct = promotion.giftProductId == null
          ? null
          : productById[promotion.giftProductId!];
      return [
        _InfoRow(
          label: 'Số lượng mua',
          value: '${promotion.buyQuantity ?? 0}',
        ),
        _InfoRow(
          label: 'Số lượng tặng',
          value: '${promotion.giftQuantity ?? 0}',
        ),
        _InfoRow(
          label: 'Sản phẩm chính',
          value: _productLabel(mainProduct, promotion.productIds),
        ),
        _InfoRow(
          label: 'Sản phẩm tặng kèm',
          value: _productLabel(giftProduct, promotion.giftProductId == null ? const [] : [promotion.giftProductId!]),
        ),
      ];
    }

    final selectedProducts = promotion.productIds
        .map((id) => productById[id])
        .whereType<Product>()
        .toList();
    return [
      _InfoRow(
        label: 'Giảm',
        value: '${promotion.discountPercent?.toStringAsFixed(0) ?? '0'}%',
      ),
      _InfoRow(
        label: 'Sản phẩm áp dụng',
        value: selectedProducts.isEmpty
            ? '-'
            : selectedProducts
                .map((product) => '${product.productName} (${product.productCode})')
                .join('\n'),
      ),
    ];
  }

  String _productLabel(Product? product, List<int> fallbackIds) {
    if (product == null) {
      return fallbackIds.isEmpty ? '-' : 'Sản phẩm #${fallbackIds.first}';
    }
    return '${product.productName} (${product.productCode})';
  }

  Future<void> _openEditSheet(BuildContext context, Promotion promotion) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: _PromotionEditForm(promotion: promotion),
        );
      },
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromotionEditForm extends StatefulWidget {
  const _PromotionEditForm({required this.promotion});
  final Promotion promotion;

  @override
  State<_PromotionEditForm> createState() => _PromotionEditFormState();
}

class _PromotionEditFormState extends State<_PromotionEditForm> {
  final _formKey = GlobalKey<FormState>();
  final _searchCtrl = TextEditingController();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _minimumOrderCtrl;
  late final TextEditingController _buyQuantityCtrl;
  late final TextEditingController _giftQuantityCtrl;
  int _promotionRule = 0;
  int? _selectedMainProductId;
  int? _selectedGiftProductId;
  final Set<int> _selectedDiscountProductIds = <int>{};

  @override
  void initState() {
    super.initState();
    final promotion = widget.promotion;
    _nameCtrl = TextEditingController(text: promotion.name);
    _discountCtrl = TextEditingController(
      text: (promotion.discountPercent ?? promotion.discountAmount ?? 10)
          .toString(),
    );
    _minimumOrderCtrl = TextEditingController(
      text: (promotion.minimumOrderAmount ?? 500000).toString(),
    );
    _buyQuantityCtrl = TextEditingController(
      text: (promotion.buyQuantity ?? 1).toString(),
    );
    _giftQuantityCtrl = TextEditingController(
      text: (promotion.giftQuantity ?? 1).toString(),
    );
    _promotionRule = promotion.type;
    if (promotion.type == 1) {
      _selectedMainProductId = promotion.productIds.isNotEmpty
          ? promotion.productIds.first
          : null;
      _selectedGiftProductId = promotion.giftProductId;
    } else if (promotion.type == 2) {
      _selectedDiscountProductIds.addAll(promotion.productIds);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _discountCtrl.dispose();
    _minimumOrderCtrl.dispose();
    _buyQuantityCtrl.dispose();
    _giftQuantityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;
    final keyword = _searchCtrl.text.trim().toLowerCase();
    final filtered = products.where((product) {
      if (keyword.isEmpty) return true;
      return product.productName.toLowerCase().contains(keyword) ||
          product.productCode.toLowerCase().contains(keyword) ||
          product.barcode.toLowerCase().contains(keyword);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sửa khuyến mãi', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên chương trình'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _promotionRule,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Giảm giá ngưỡng hóa đơn')),
                  DropdownMenuItem(value: 1, child: Text('Mua X tặng Y')),
                  DropdownMenuItem(value: 2, child: Text('Giảm giá sản phẩm')),
                ],
                onChanged: (value) => setState(() => _promotionRule = value ?? 0),
              ),
              const SizedBox(height: 12),
              if (_promotionRule == 0) ...[
                TextFormField(
                  controller: _minimumOrderCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ngưỡng hóa đơn',
                    suffixText: 'đ',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _discountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Phần trăm giảm',
                    suffixText: '%',
                  ),
                ),
              ] else if (_promotionRule == 1) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _buyQuantityCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Số lượng mua'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _giftQuantityCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Số lượng tặng'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ProductPicker(
                  title: 'Sản phẩm chính',
                  products: filtered,
                  selectedProductIds: _selectedMainProductId == null
                      ? <int>{}
                      : <int>{_selectedMainProductId!},
                  allowMultiple: false,
                  onChanged: (ids) {
                    setState(() {
                      _selectedMainProductId = ids.isEmpty ? null : ids.first;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _ProductPicker(
                  title: 'Sản phẩm tặng kèm',
                  products: filtered,
                  selectedProductIds: _selectedGiftProductId == null
                      ? <int>{}
                      : <int>{_selectedGiftProductId!},
                  allowMultiple: false,
                  onChanged: (ids) {
                    setState(() {
                      _selectedGiftProductId = ids.isEmpty ? null : ids.first;
                    });
                  },
                ),
              ] else ...[
                TextFormField(
                  controller: _discountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Phần trăm giảm',
                    suffixText: '%',
                  ),
                ),
                const SizedBox(height: 12),
                _ProductPicker(
                  title: 'Sản phẩm áp dụng',
                  products: filtered,
                  selectedProductIds: _selectedDiscountProductIds,
                  allowMultiple: true,
                  onChanged: (ids) {
                    setState(() {
                      _selectedDiscountProductIds
                        ..clear()
                        ..addAll(ids);
                    });
                  },
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _save,
                child: const Text('Lưu thay đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final promotionType = _promotionRule;
    final provider = context.read<PromotionProvider>();
    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'description': _buildDescription(),
      'type': promotionType,
      'discountPercent': promotionType == 0 || promotionType == 2
          ? double.tryParse(_discountCtrl.text.trim())
          : null,
      'discountAmount': null,
      'minimumOrderAmount': promotionType == 0
          ? double.tryParse(_minimumOrderCtrl.text.trim())
          : null,
      'buyQuantity': promotionType == 1
          ? int.tryParse(_buyQuantityCtrl.text.trim())
          : null,
      'giftQuantity': promotionType == 1
          ? int.tryParse(_giftQuantityCtrl.text.trim())
          : null,
      'giftProductId': promotionType == 1 ? _selectedGiftProductId : null,
      'startDate': widget.promotion.startDate.toIso8601String(),
      'endDate': widget.promotion.endDate.toIso8601String(),
      'isActive': widget.promotion.isActive,
      'productIds': promotionType == 1
          ? <int>[_selectedMainProductId!]
          : _selectedDiscountProductIds.toList(),
    };

    final ok = await provider.updatePromotion(widget.promotion.promotionId, data);
    if (ok && mounted) Navigator.pop(context);
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
}

class _ProductPicker extends StatefulWidget {
  const _ProductPicker({
    required this.title,
    required this.products,
    required this.selectedProductIds,
    required this.allowMultiple,
    required this.onChanged,
  });

  final String title;
  final List<Product> products;
  final Set<int> selectedProductIds;
  final bool allowMultiple;
  final ValueChanged<Set<int>> onChanged;

  @override
  State<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<_ProductPicker> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyword = _searchCtrl.text.trim().toLowerCase();
    final filtered = widget.products.where((product) {
      if (keyword.isEmpty) return true;
      return product.productName.toLowerCase().contains(keyword) ||
          product.productCode.toLowerCase().contains(keyword) ||
          product.barcode.toLowerCase().contains(keyword);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Tìm theo tên, mã hoặc barcode',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filtered.map((product) {
            final selected = widget.selectedProductIds.contains(product.productId);
            return FilterChip(
              selected: selected,
              label: Text('${product.productName} (${product.productCode})'),
              onSelected: (value) {
                final next = <int>{...widget.selectedProductIds};
                if (widget.allowMultiple) {
                  if (value) {
                    next.add(product.productId);
                  } else {
                    next.remove(product.productId);
                  }
                } else {
                  next
                    ..clear()
                    ..add(product.productId);
                  if (!value) next.clear();
                }
                widget.onChanged(next);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
