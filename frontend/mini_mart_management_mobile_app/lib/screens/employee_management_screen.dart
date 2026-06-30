import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/employee.dart';
import 'package:mini_mart_management_mobile_app/providers/employee_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/category_management_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/loading_overlay.dart';
import 'package:provider/provider.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().fetchEmployees();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    final employees = provider.employees;
    final isLoading = provider.isLoading;
    final error = provider.error;

    // Filtered employees list
    final filteredEmployees = employees.where((e) {
      return e.fullName.toLowerCase().contains(_searchQuery) ||
          e.username.toLowerCase().contains(_searchQuery) ||
          e.roleName.toLowerCase().contains(_searchQuery);
    }).toList();

    // Stats calculations
    final totalCount = employees.length;
    final adminCount = employees.where((e) => e.roleId == 4).length;
    final activeCount = employees.where((e) => e.status == 1).length;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Action Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quản lý người dùng',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            FilledButton.icon(
                              onPressed: () => _showAddEmployeeDialog(context),
                              icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                              label: const Text('Add User'),
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
                        // Search Bar
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded),
                            hintText: 'Tìm kiếm nhân viên...',
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Density Statistics
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard('Tổng số', '$totalCount', AppColors.primary),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard('Admin', '$adminCount', AppColors.primaryContainer),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard('Đang trực', '$activeCount', AppColors.secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (error != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.statusError, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              error,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.statusError),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<EmployeeProvider>().fetchEmployees(),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (!isLoading && filteredEmployees.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('Không tìm thấy nhân viên nào.'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    sliver: SliverList.separated(
                      itemCount: filteredEmployees.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final emp = filteredEmployees[index];
                        return _buildEmployeeCard(context, emp);
                      },
                    ),
                  ),
              ],
            ),
            if (isLoading) const LoadingOverlay(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đang quét mã vạch...')),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceContainerLowest,
        child: const Icon(Icons.qr_code_scanner_rounded),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
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
              child: Icon(Icons.person_rounded, size: 20, color: AppColors.primary),
            ),
          ),
        ),
      ],
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
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color == AppColors.secondary ? color : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, Employee emp) {
    final initials = emp.fullName.trim().split(' ').last.substring(0, 2).toUpperCase();
    final isActive = emp.status == 1;

    // Role badge colors
    Color badgeBg;
    Color badgeText;
    switch (emp.roleId) {
      case 4: // Admin
        badgeBg = AppColors.primaryContainer;
        badgeText = AppColors.primary;
        break;
      case 1: // Manager
        badgeBg = const Color(0xFF6CF8BB).withValues(alpha: 0.2);
        badgeText = const Color(0xFF00714D);
        break;
      default: // Cashier, Warehouse
        badgeBg = AppColors.borderGray;
        badgeText = AppColors.textDark;
    }

    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Container(
        padding: const EdgeInsets.all(16),
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              emp.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                emp.roleName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: badgeText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: (val) {
                    context.read<EmployeeProvider>().toggleEmployeeStatus(emp.employeeId, emp.status);
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF006C49),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: AppColors.borderGray,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Column(
                children: [
                  if (emp.email != null && emp.email!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.mail_outline_rounded, size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          emp.email!,
                          style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  if (emp.email != null && emp.email!.isNotEmpty) const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.call_outlined, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text(
                        emp.phoneNumber,
                        style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditEmployeeDialog(context, emp),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: 2,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryContainer,
      onDestinationSelected: (index) {
        if (index == 0 || index == 1) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
          );
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Catalog',
        ),
        NavigationDestination(
          icon: Icon(Icons.category_outlined),
          label: 'Categories',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.group_rounded),
          icon: Icon(Icons.group_outlined),
          label: 'Staff',
        ),
        NavigationDestination(
          icon: Icon(Icons.payments_outlined),
          label: 'Finance',
        ),
      ],
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EmployeeFormSheet(
        onSave: (data) async {
          final success = await context.read<EmployeeProvider>().createEmployee(data);
          if (success && ctx.mounted) {
            Navigator.pop(ctx);
          }
        },
      ),
    );
  }

  void _showEditEmployeeDialog(BuildContext context, Employee emp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EmployeeFormSheet(
        employee: emp,
        onSave: (data) async {
          final success = await context.read<EmployeeProvider>().updateEmployee(emp.employeeId, data);
          if (success && ctx.mounted) {
            Navigator.pop(ctx);
          }
        },
      ),
    );
  }
}

class _EmployeeFormSheet extends StatefulWidget {
  const _EmployeeFormSheet({this.employee, required this.onSave});

  final Employee? employee;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  @override
  State<_EmployeeFormSheet> createState() => _EmployeeFormSheetState();
}

class _EmployeeFormSheetState extends State<_EmployeeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _fullName;
  late String _username;
  late String _password;
  late String _phoneNumber;
  String? _email;
  String? _address;
  late double _salary;
  late bool _gender;
  late int _roleId;
  late int _status;
  late DateTime _dateOfBirth;
  late DateTime _hireDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final emp = widget.employee;
    _fullName = emp?.fullName ?? '';
    _username = emp?.username ?? '';
    _password = '';
    _phoneNumber = emp?.phoneNumber ?? '';
    _email = emp?.email;
    _address = emp?.address;
    _salary = emp?.salary ?? 8000000;
    _gender = emp?.gender ?? true; // true = Male
    _roleId = emp?.roleId ?? 2; // default Cashier
    _status = emp?.status ?? 1; // default Active
    _dateOfBirth = emp?.dateOfBirth ?? DateTime(1995, 1, 1);
    _hireDate = emp?.hireDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.employee != null;

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
                isEdit ? 'Cập nhật nhân viên' : 'Thêm nhân viên mới',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _fullName,
                decoration: const InputDecoration(labelText: 'Họ và tên *'),
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập họ và tên' : null,
                onSaved: (val) => _fullName = val!,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _username,
                      decoration: const InputDecoration(labelText: 'Tên đăng nhập *'),
                      enabled: !isEdit,
                      validator: (val) => val == null || val.isEmpty ? 'Nhập tên đăng nhập' : null,
                      onSaved: (val) => _username = val!,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<bool>(
                      initialValue: _gender,
                      decoration: const InputDecoration(labelText: 'Giới tính'),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Nam')),
                        DropdownMenuItem(value: false, child: Text('Nữ')),
                      ],
                      onChanged: (val) => setState(() => _gender = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: isEdit ? 'Mật khẩu mới (bỏ trống nếu giữ nguyên)' : 'Mật khẩu *',
                ),
                obscureText: true,
                validator: (val) {
                  if (!isEdit && (val == null || val.isEmpty)) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
                onSaved: (val) => _password = val ?? '',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _phoneNumber,
                      decoration: const InputDecoration(labelText: 'Số điện thoại *'),
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.isEmpty ? 'Nhập số điện thoại' : null,
                      onSaved: (val) => _phoneNumber = val!,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _salary.toStringAsFixed(0),
                      decoration: const InputDecoration(labelText: 'Lương (VND)'),
                      keyboardType: TextInputType.number,
                      onSaved: (val) => _salary = double.tryParse(val ?? '') ?? 8000000,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => _email = val,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
                onSaved: (val) => _address = val,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _roleId,
                      decoration: const InputDecoration(labelText: 'Vai trò'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Manager')),
                        DropdownMenuItem(value: 2, child: Text('Cashier')),
                        DropdownMenuItem(value: 3, child: Text('Warehouse')),
                        DropdownMenuItem(value: 4, child: Text('Admin')),
                      ],
                      onChanged: (val) => setState(() => _roleId = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Trạng thái'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Hoạt động')),
                        DropdownMenuItem(value: 0, child: Text('Vô hiệu hóa')),
                      ],
                      onChanged: (val) => setState(() => _status = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ngày sinh: ${_dateOfBirth.day}/${_dateOfBirth.month}/${_dateOfBirth.year}'),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dateOfBirth,
                        firstDate: DateTime(1960),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _dateOfBirth = picked);
                      }
                    },
                    child: const Text('Chọn'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ngày vào làm: ${_hireDate.day}/${_hireDate.month}/${_hireDate.year}'),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _hireDate,
                        firstDate: DateTime(2015),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _hireDate = picked);
                      }
                    },
                    child: const Text('Chọn'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Lưu'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);

    final payload = <String, dynamic>{
      'fullName': _fullName,
      'gender': _gender,
      'dateOfBirth': _dateOfBirth.toIso8601String(),
      'phoneNumber': _phoneNumber,
      'email': _email,
      'address': _address,
      'username': _username,
      'salary': _salary,
      'hireDate': _hireDate.toIso8601String(),
      'status': _status,
      'roleId': _roleId,
    };

    if (_password.isNotEmpty) {
      payload['password'] = _password;
    }

    try {
      await widget.onSave(payload);
    } catch (_) {
      // Handled by provider error
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
