import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/supplier.dart';
import 'package:mini_mart_management_mobile_app/providers/supplier_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';

class SupplierDetailScreen extends StatefulWidget {
  const SupplierDetailScreen({this.supplierId, super.key});

  final int? supplierId;

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _taxCodeCtrl = TextEditingController();
  final _bankAccountCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  bool _status = true;
  bool _isLoading = false;
  bool _isSaving = false;
  Supplier? _supplier;

  bool get _isNew => widget.supplierId == null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isNew) return;
      setState(() => _isLoading = true);
      final provider = context.read<SupplierProvider>();
      if (provider.suppliers.isEmpty) {
        await provider.fetchSuppliers();
      }
      Supplier? found;
      for (final supplier in provider.suppliers) {
        if (supplier.supplierId == widget.supplierId) {
          found = supplier;
          break;
        }
      }
      if (!mounted) return;
      _supplier = found;
      _fill(found);
      setState(() => _isLoading = false);
    });
  }

  void _fill(Supplier? supplier) {
    _codeCtrl.text = supplier?.supplierCode ?? '';
    _nameCtrl.text = supplier?.supplierName ?? '';
    _contactCtrl.text = supplier?.contactPerson ?? '';
    _phoneCtrl.text = supplier?.phoneNumber ?? '';
    _emailCtrl.text = supplier?.email ?? '';
    _addressCtrl.text = supplier?.address ?? '';
    _taxCodeCtrl.text = supplier?.taxCode ?? '';
    _bankAccountCtrl.text = supplier?.bankAccount ?? '';
    _bankNameCtrl.text = supplier?.bankName ?? '';
    _descCtrl.text = supplier?.description ?? '';
    _status = supplier?.status ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _taxCodeCtrl.dispose();
    _bankAccountCtrl.dispose();
    _bankNameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'supplierCode': _codeCtrl.text.trim(),
      'supplierName': _nameCtrl.text.trim(),
      'contactPerson': _contactCtrl.text.trim().isEmpty ? null : _contactCtrl.text.trim(),
      'phoneNumber': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      'address': _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      'taxCode': _taxCodeCtrl.text.trim().isEmpty ? null : _taxCodeCtrl.text.trim(),
      'bankAccount': _bankAccountCtrl.text.trim().isEmpty ? null : _bankAccountCtrl.text.trim(),
      'bankName': _bankNameCtrl.text.trim().isEmpty ? null : _bankNameCtrl.text.trim(),
      'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'status': _status,
    };
    final provider = context.read<SupplierProvider>();
    final ok = _isNew
        ? await provider.createSupplier(data)
        : await provider.updateSupplier(widget.supplierId!, data);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Không thể lưu nhà cung cấp.')),
      );
    }
  }

  Future<void> _delete() async {
    final supplier = _supplier;
    if (supplier == null) return;
    final ok = await context.read<SupplierProvider>().deleteSupplier(supplier.supplierId);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<SupplierProvider>().error ?? 'Không thể xóa nhà cung cấp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: SafeArea(child: LoadingOverlay()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Thêm Nhà Cung Cấp' : 'Chi tiết Nhà Cung Cấp'),
        backgroundColor: AppColors.surfaceContainerLowest,
        foregroundColor: AppColors.primary,
        actions: [
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
              tooltip: 'Xóa',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _field(_codeCtrl, 'Mã NCC *'),
                const SizedBox(height: 12),
                _field(_nameCtrl, 'Tên nhà cung cấp *'),
                const SizedBox(height: 12),
                _field(_phoneCtrl, 'Số điện thoại *'),
                const SizedBox(height: 12),
                _field(_contactCtrl, 'Người liên hệ'),
                const SizedBox(height: 12),
                _field(_emailCtrl, 'Email'),
                const SizedBox(height: 12),
                _field(_addressCtrl, 'Địa chỉ'),
                const SizedBox(height: 12),
                _field(_taxCodeCtrl, 'Mã số thuế'),
                const SizedBox(height: 12),
                _field(_bankAccountCtrl, 'Số tài khoản'),
                const SizedBox(height: 12),
                _field(_bankNameCtrl, 'Ngân hàng'),
                const SizedBox(height: 12),
                _field(_descCtrl, 'Mô tả', maxLines: 3),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _status,
                  onChanged: (value) => setState(() => _status = value),
                  title: const Text('Đang hoạt động'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: const Text('Lưu'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (label.endsWith('*') && (value == null || value.trim().isEmpty)) {
          return 'Không được trống';
        }
        return null;
      },
    );
  }
}
