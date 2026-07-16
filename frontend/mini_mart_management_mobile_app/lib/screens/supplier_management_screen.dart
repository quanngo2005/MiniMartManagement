import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/supplier.dart';
import 'package:mini_mart_management_mobile_app/providers/supplier_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/app_bottom_nav_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/suppliers/supplier_card.dart';
import 'package:provider/provider.dart';

class SupplierManagementScreen extends StatefulWidget {
  const SupplierManagementScreen({super.key});

  @override
  State<SupplierManagementScreen> createState() =>
      _SupplierManagementScreenState();
}

class _SupplierManagementScreenState extends State<SupplierManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierProvider>().fetchSuppliers();
    });
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierProvider>();

    final filtered = provider.suppliers.where((s) {
      return s.supplierName.toLowerCase().contains(_searchQuery) ||
          s.supplierCode.toLowerCase().contains(_searchQuery) ||
          (s.contactPerson?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    final totalCount = provider.suppliers.length;
    final activeCount = provider.suppliers.where((s) => s.status).length;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(context, totalCount, activeCount),
                ),
                if (provider.error != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildError(context, provider.error!),
                  )
                else if (!provider.isLoading && filtered.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('Không tìm thấy nhà cung cấp nào.'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => SupplierCard(
                        supplier: filtered[i],
                        onEdit: () =>
                            _showFormSheet(context, supplier: filtered[i]),
                        onDelete: () => _confirmDelete(context, filtered[i]),
                      ),
                    ),
                  ),
              ],
            ),
            if (provider.isLoading) const LoadingOverlay(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceContainerLowest,
        tooltip: 'Thêm nhà cung cấp',
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      titleSpacing: 16,
      leadingWidth: 40,
      leading: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Icon(Icons.storefront_rounded, color: AppColors.primary),
      ),
      title: Text(
        'Store #402 | North Branch',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryContainer,
              border: Border.all(color: AppColors.borderGray),
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, int total, int active) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nhà cung cấp',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showFormSheet(context),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Thêm mới'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Tìm kiếm tên, mã, người liên hệ...',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Tổng số', '$total', AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Hoạt động',
                  '$active',
                  AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Ngừng HT',
                  '${total - active}',
                  AppColors.statusError,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.statusError,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.statusError),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<SupplierProvider>().fetchSuppliers(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return const AppBottomNavBar(selectedTab: AppNavTab.suppliers);
  }

  void _showFormSheet(BuildContext context, {Supplier? supplier}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _SupplierFormSheet(
        supplier: supplier,
        onSave: (data) async {
          bool success;
          if (supplier == null) {
            success = await context.read<SupplierProvider>().createSupplier(
              data,
            );
          } else {
            success = await context.read<SupplierProvider>().updateSupplier(
              supplier.supplierId,
              data,
            );
          }
          if (success && ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Xóa nhà cung cấp "${supplier.supplierName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<SupplierProvider>().deleteSupplier(
                supplier.supplierId,
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.statusError),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

// ── Form Sheet ───────────────────────────────────────────────────────────────

class _SupplierFormSheet extends StatefulWidget {
  const _SupplierFormSheet({this.supplier, required this.onSave});

  final Supplier? supplier;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  @override
  State<_SupplierFormSheet> createState() => _SupplierFormSheetState();
}

class _SupplierFormSheetState extends State<_SupplierFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late String _supplierCode;
  late String _supplierName;
  late String _phoneNumber;
  String? _contactPerson;
  String? _email;
  String? _address;
  String? _taxCode;
  String? _bankAccount;
  String? _bankName;
  String? _description;
  late bool _status;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _supplierCode = s?.supplierCode ?? '';
    _supplierName = s?.supplierName ?? '';
    _phoneNumber = s?.phoneNumber ?? '';
    _contactPerson = s?.contactPerson;
    _email = s?.email;
    _address = s?.address;
    _taxCode = s?.taxCode;
    _bankAccount = s?.bankAccount;
    _bankName = s?.bankName;
    _description = s?.description;
    _status = s?.status ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEdit ? 'Cập nhật nhà cung cấp' : 'Thêm nhà cung cấp mới',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _supplierCode,
                      decoration: const InputDecoration(labelText: 'Mã NCC *'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Nhập mã NCC' : null,
                      onSaved: (v) => _supplierCode = v!,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _phoneNumber,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại *',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Nhập số điện thoại' : null,
                      onSaved: (v) => _phoneNumber = v!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _supplierName,
                decoration: const InputDecoration(
                  labelText: 'Tên nhà cung cấp *',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nhập tên nhà cung cấp' : null,
                onSaved: (v) => _supplierName = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _contactPerson,
                decoration: const InputDecoration(labelText: 'Người liên hệ'),
                onSaved: (v) => _contactPerson = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (v) => _email = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
                onSaved: (v) => _address = v,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _taxCode,
                      decoration: const InputDecoration(
                        labelText: 'Mã số thuế',
                      ),
                      onSaved: (v) => _taxCode = v,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<bool>(
                      value: _status,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                      ),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Hoạt động')),
                        DropdownMenuItem(
                          value: false,
                          child: Text('Ngừng hợp tác'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _bankAccount,
                      decoration: const InputDecoration(
                        labelText: 'Số tài khoản',
                      ),
                      onSaved: (v) => _bankAccount = v,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _bankName,
                      decoration: const InputDecoration(labelText: 'Ngân hàng'),
                      onSaved: (v) => _bankName = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
                maxLines: 2,
                onSaved: (v) => _description = v,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isSaving ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isEdit ? 'Cập nhật' : 'Thêm mới'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSaving = true);
    await widget.onSave({
      'supplierCode': _supplierCode,
      'supplierName': _supplierName,
      'phoneNumber': _phoneNumber,
      'contactPerson': _contactPerson,
      'email': _email,
      'address': _address,
      'taxCode': _taxCode,
      'bankAccount': _bankAccount,
      'bankName': _bankName,
      'description': _description,
      'status': _status,
    });
    if (mounted) setState(() => _isSaving = false);
  }
}
