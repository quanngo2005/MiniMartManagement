import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/receipt.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class CreateInventoryReceiptScreen extends StatefulWidget {
  const CreateInventoryReceiptScreen({super.key});

  @override
  State<CreateInventoryReceiptScreen> createState() =>
      _CreateInventoryReceiptScreenState();
}

class _CreateInventoryReceiptScreenState
    extends State<CreateInventoryReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiptCodeController = TextEditingController(
    text: 'IMP-20231025-001',
  );
  final _supplierIdController = TextEditingController(text: '1');
  final _employeeIdController = TextEditingController(text: '1');
  final _paidAmountController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  final List<_ReceiptLineDraft> _lines = [_ReceiptLineDraft()];

  DateTime _importDate = DateTime.now();
  ReceiptStatus _status = ReceiptStatus.pending;

  @override
  void dispose() {
    _receiptCodeController.dispose();
    _supplierIdController.dispose();
    _employeeIdController.dispose();
    _paidAmountController.dispose();
    _noteController.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                sliver: SliverList.list(
                  children: [
                    _buildDocumentSection(context),
                    const SizedBox(height: 12),
                    _buildAmountSection(context),
                    const SizedBox(height: 12),
                    _buildLineSection(context),
                    const SizedBox(height: 12),
                    _buildNoteSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildActionBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceBright,
      foregroundColor: AppColors.primary,
      title: Text(
        'Tạo phiếu nhập',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildDocumentSection(BuildContext context) {
    return _FormPanel(
      title: 'Thông tin chứng từ',
      icon: Icons.receipt_long_outlined,
      children: [
        TextFormField(
          controller: _receiptCodeController,
          decoration: const InputDecoration(labelText: 'Mã phiếu nhập'),
          textInputAction: TextInputAction.next,
          validator: _requiredValidator,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickImportDate,
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Ngày nhập',
              suffixIcon: Icon(Icons.calendar_today_outlined),
            ),
            child: Text(_formatDate(_importDate)),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ReceiptStatus>(
          initialValue: _status,
          decoration: const InputDecoration(labelText: 'Trạng thái'),
          items: ReceiptStatus.values
              .map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(_statusLabel(status)),
                ),
              )
              .toList(),
          onChanged: (status) {
            if (status == null) return;
            setState(() => _status = status);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _supplierIdController,
                decoration: const InputDecoration(labelText: 'Mã NCC'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: _positiveIntValidator,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _employeeIdController,
                decoration: const InputDecoration(labelText: 'Mã nhân viên'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: _positiveIntValidator,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    final totalAmount = _totalAmount;
    final paidAmount = _readDouble(_paidAmountController.text);
    final debtAmount = (totalAmount - paidAmount)
        .clamp(0, double.infinity)
        .toDouble();

    return _FormPanel(
      title: 'Thanh toán',
      icon: Icons.payments_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _AmountSummary(
                label: 'Tạm tính',
                value: _formatCurrency(totalAmount),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AmountSummary(
                label: 'Còn nợ',
                value: _formatCurrency(debtAmount),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _paidAmountController,
          decoration: const InputDecoration(labelText: 'Đã thanh toán'),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          validator: _moneyValidator,
        ),
      ],
    );
  }

  Widget _buildLineSection(BuildContext context) {
    return _FormPanel(
      title: 'Sản phẩm nhập',
      icon: Icons.inventory_2_outlined,
      trailing: IconButton(
        onPressed: _addLine,
        tooltip: 'Thêm dòng hàng',
        icon: const Icon(Icons.add_circle_outline_rounded),
      ),
      children: [
        for (final (index, line) in _lines.indexed) ...[
          if (index > 0) const Divider(height: 28, color: AppColors.borderGray),
          _ReceiptLineFields(
            line: line,
            canRemove: _lines.length > 1,
            onChanged: () => setState(() {}),
            onRemove: () => _removeLine(line),
          ),
        ],
      ],
    );
  }

  Widget _buildNoteSection(BuildContext context) {
    return _FormPanel(
      title: 'Ghi chú',
      icon: Icons.notes_outlined,
      children: [
        TextFormField(
          controller: _noteController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Ghi chú cho phiếu nhập'),
        ),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.borderGray)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(0, 48),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Tạo phiếu'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surfaceContainerLowest,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addLine() {
    setState(() => _lines.add(_ReceiptLineDraft()));
  }

  void _removeLine(_ReceiptLineDraft line) {
    setState(() {
      _lines.remove(line);
      line.dispose();
    });
  }

  Future<void> _pickImportDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _importDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;
    setState(() => _importDate = pickedDate);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final totalAmount = _totalAmount;
    final paidAmount = _readDouble(_paidAmountController.text);
    final receipt = CreateReceipt(
      receiptCode: _receiptCodeController.text.trim(),
      importDate: _importDate,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      debtAmount: (totalAmount - paidAmount).clamp(0, double.infinity),
      receiptStatus: _status,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      supplierId: int.parse(_supplierIdController.text.trim()),
      employeeId: int.parse(_employeeIdController.text.trim()),
      batchLines: _lines.map((line) => line.toReceiptBatchLine()).toList(),
    );

    Navigator.of(context).pop(receipt);
  }

  double get _totalAmount {
    return _lines.fold(0, (total, line) => total + line.lineTotal);
  }

  static String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập dữ liệu';
    return null;
  }

  static String? _positiveIntValidator(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) return 'Nhập số lớn hơn 0';
    return null;
  }

  static String? _moneyValidator(String? value) {
    final parsed = _readDouble(value ?? '');
    if (parsed < 0) return 'Nhập số tiền hợp lệ';
    return null;
  }

  static double _readDouble(String value) {
    return double.tryParse(value.trim().replaceAll(',', '')) ?? 0;
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _formatCurrency(double value) {
    final roundedValue = value.round().toString();
    final buffer = StringBuffer();
    for (var index = 0; index < roundedValue.length; index++) {
      final remaining = roundedValue.length - index;
      buffer.write(roundedValue[index]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }
    return '$bufferđ';
  }

  static String _statusLabel(ReceiptStatus status) {
    return switch (status) {
      ReceiptStatus.pending => 'Chờ xử lý',
      ReceiptStatus.completed => 'Hoàn thành',
      ReceiptStatus.cancelled => 'Đã hủy',
    };
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _AmountSummary extends StatelessWidget {
  const _AmountSummary({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptLineFields extends StatelessWidget {
  const _ReceiptLineFields({
    required this.line,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final _ReceiptLineDraft line;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: line.batchCodeController,
                decoration: const InputDecoration(labelText: 'Mã lô'),
                textInputAction: TextInputAction.next,
                validator:
                    _CreateInventoryReceiptScreenState._requiredValidator,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: canRemove ? onRemove : null,
              tooltip: 'Xóa dòng hàng',
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: line.barcodeController,
          decoration: const InputDecoration(labelText: 'Barcode / SKU'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: line.quantityController,
                decoration: const InputDecoration(labelText: 'Số lượng'),
                keyboardType: TextInputType.number,
                onChanged: (_) => onChanged(),
                validator:
                    _CreateInventoryReceiptScreenState._positiveIntValidator,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: line.importPriceController,
                decoration: const InputDecoration(labelText: 'Giá nhập'),
                keyboardType: TextInputType.number,
                onChanged: (_) => onChanged(),
                validator: _CreateInventoryReceiptScreenState._moneyValidator,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DateField(
                label: 'Ngày SX',
                date: line.manufactureDate,
                onTap: () => line.pickManufactureDate(context, onChanged),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateField(
                label: 'Hạn dùng',
                date: line.expiryDate,
                onTap: () => line.pickExpiryDate(context, onChanged),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.event_outlined),
        ),
        child: Text(_CreateInventoryReceiptScreenState._formatDate(date)),
      ),
    );
  }
}

class _ReceiptLineDraft {
  _ReceiptLineDraft()
    : manufactureDate = DateTime.now(),
      expiryDate = DateTime.now().add(const Duration(days: 180));

  final batchCodeController = TextEditingController(text: 'BATCH-001');
  final barcodeController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final importPriceController = TextEditingController(text: '0');
  DateTime manufactureDate;
  DateTime expiryDate;

  double get lineTotal {
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    final importPrice =
        double.tryParse(
          importPriceController.text.trim().replaceAll(',', ''),
        ) ??
        0;
    return quantity * importPrice;
  }

  ReceiptBatchLine toReceiptBatchLine() {
    return ReceiptBatchLine(
      barcode: barcodeController.text.trim().isEmpty
          ? null
          : barcodeController.text.trim(),
      batchCode: batchCodeController.text.trim(),
      manufactureDate: manufactureDate,
      expiryDate: expiryDate,
      importPrice: double.parse(
        importPriceController.text.trim().replaceAll(',', ''),
      ),
      quantity: int.parse(quantityController.text.trim()),
    );
  }

  Future<void> pickManufactureDate(
    BuildContext context,
    VoidCallback onChanged,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: manufactureDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;
    manufactureDate = pickedDate;
    onChanged();
  }

  Future<void> pickExpiryDate(
    BuildContext context,
    VoidCallback onChanged,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: expiryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;
    expiryDate = pickedDate;
    onChanged();
  }

  void dispose() {
    batchCodeController.dispose();
    barcodeController.dispose();
    quantityController.dispose();
    importPriceController.dispose();
  }
}
