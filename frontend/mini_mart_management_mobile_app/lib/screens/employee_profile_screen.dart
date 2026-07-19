import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/shift_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/login_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/cashier_bottom_navigation_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/cashier_drawer.dart';
import 'package:mini_mart_management_mobile_app/widgets/profile/profile_detail_row.dart';
import 'package:provider/provider.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({
    super.key,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor = AppColors.surfaceContainerLow,
  }) : cashierLayout = false;

  const EmployeeProfileScreen.cashier({super.key})
    : appBar = null,
      bottomNavigationBar = null,
      backgroundColor = AppColors.backgroundSlate,
      cashierLayout = true;

  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color backgroundColor;
  final bool cashierLayout;

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchCurrentUser();
    });
  }

  void _showLogoutConfirmation() {
    final shift = context.read<ShiftProvider>().currentShift;
    if (shift != null) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'Không thể đăng xuất',
            style: TextStyle(color: AppColors.statusError),
          ),
          content: const Text(
            'Bạn đang có ca làm việc đang hoạt động. Vui lòng kết thúc ca làm việc (vào màn hình Mở/Đóng ca) trước khi đăng xuất để đảm bảo bàn giao tiền mặt chính xác.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Đã hiểu'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi hệ thống không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusError,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      drawer: widget.cashierLayout
          ? const CashierDrawer(selectedTab: CashierNavTab.profile)
          : null,
      appBar: widget.cashierLayout
          ? const MiniMartAppBar.primary(title: 'Cá nhân', showMenu: true)
          : widget.appBar ??
                const MiniMartAppBar.secondary(title: 'Hồ sơ & Cài đặt'),
      body: SafeArea(
        child: authProvider.isLoading && user == null
            ? const LoadingOverlay()
            : authProvider.errorMessage != null && user == null
            ? ErrorBanner(message: authProvider.errorMessage!)
            : user == null
            ? const Center(child: Text('Không tìm thấy thông tin nhân viên.'))
            : _buildBody(context, user),
      ),
      bottomNavigationBar: widget.cashierLayout
          ? const CashierBottomNavigationBar(selectedTab: CashierNavTab.profile)
          : widget.bottomNavigationBar,
    );
  }

  Widget _buildBody(BuildContext context, EmployeeUser user) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final initials = _avatarText(user.fullName);

    return RefreshIndicator(
      onRefresh: () => context.read<AuthProvider>().fetchCurrentUser(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      initials,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.roleName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                children: [
                  ProfileDetailRow(label: 'Họ tên', value: user.fullName),
                  ProfileDetailRow(
                    label: 'Giới tính',
                    value: user.gender ? 'Nam' : 'Nữ',
                  ),
                  ProfileDetailRow(
                    label: 'Ngày sinh',
                    value: dateFormat.format(user.dateOfBirth),
                  ),
                  ProfileDetailRow(
                    label: 'Email',
                    value: user.email ?? 'Chưa cập nhật',
                  ),
                  ProfileDetailRow(
                    label: 'Địa chỉ',
                    value: user.address ?? 'Chưa cập nhật',
                  ),
                  ProfileDetailRow(
                    label: 'Tên đăng nhập',
                    value: '@${user.username}',
                  ),
                  ProfileDetailRow(
                    label: 'Vai trò',
                    value: user.roleName.toUpperCase(),
                    isBadge: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.statusError.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.statusError,
                  ),
                ),
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.statusError,
                  ),
                ),
                subtitle: const Text(
                  'Thoát khỏi tài khoản hiện tại',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                onTap: _showLogoutConfirmation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _avatarText(String fullName) {
    if (fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}
