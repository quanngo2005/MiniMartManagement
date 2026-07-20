import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_mart_management_mobile_app/models/shift.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart_management_mobile_app/providers/employee_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/shift_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/cashier_bottom_navigation_bar.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/cashier_drawer.dart';
import 'package:mini_mart_management_mobile_app/widgets/layout/mini_mart_app_bar.dart';
import 'package:provider/provider.dart';

class ShiftManagementScreen extends StatefulWidget {
  const ShiftManagementScreen({this.onMenuTap, super.key});

  final VoidCallback? onMenuTap;

  @override
  State<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _pulseController;
  final _startCashController = TextEditingController(text: '1000000');
  final _endCashController = TextEditingController();
  final _openNoteController = TextEditingController();
  final _closeNoteController = TextEditingController();
  int? _endCashInitializedForShiftId;
  bool _isProcessing = false;
  int _selectedShiftType = 0;

  @override
  void initState() {
    super.initState();
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) {
      _selectedShiftType = 0;
    } else if (hour >= 11 && hour < 16) {
      _selectedShiftType = 1;
    } else {
      _selectedShiftType = 2;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = context.read<AuthProvider>().currentUser;
      final isManager =
          currentUser?.roleName == 'Manager' ||
          currentUser?.roleName == 'Admin';
      final shiftProvider = context.read<ShiftProvider>();

      if (isManager) {
        shiftProvider.fetchShifts();
        context.read<EmployeeProvider>().fetchEmployees();
      } else {
        shiftProvider.fetchCurrentShift();
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && context.read<ShiftProvider>().currentShift != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _startCashController.dispose();
    _endCashController.dispose();
    _openNoteController.dispose();
    _closeNoteController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final str = amount.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  Future<void> _handleOpenShift(int cashierId) async {
    final startCash =
        double.tryParse(_startCashController.text.replaceAll('.', '')) ?? 0.0;
    if (startCash <= 0) {
      _showErrorSnackBar('Vui lòng nhập tiền mặt đầu ca hợp lệ.');
      return;
    }

    setState(() => _isProcessing = true);
    final success = await context.read<ShiftProvider>().openNewShift(
      cashierId: cashierId,
      startCash: startCash,
      shiftType: _selectedShiftType,
      note: _openNoteController.text.trim().isEmpty
          ? null
          : _openNoteController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      _openNoteController.clear();
      _showSuccessSnackBar('Đã mở ca làm việc thành công.');
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      final error =
          context.read<ShiftProvider>().error ?? 'Không thể mở ca làm việc.';
      _showErrorSnackBar(error);
    }
  }

  Future<void> _handleCloseShift(int shiftId) async {
    final endCash = double.tryParse(_endCashController.text) ?? -1.0;
    if (endCash < 0) {
      _showErrorSnackBar('Vui lòng nhập số tiền mặt cuối ca thực tế.');
      return;
    }

    setState(() => _isProcessing = true);
    final success = await context.read<ShiftProvider>().closeShift(
      shiftId: shiftId,
      endCash: endCash,
      note: _closeNoteController.text.trim().isEmpty
          ? null
          : _closeNoteController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      _endCashController.clear();
      _endCashInitializedForShiftId = null;
      _closeNoteController.clear();
      _showSuccessSnackBar('Đã đóng ca làm việc và chốt doanh thu thành công.');
    } else {
      final error =
          context.read<ShiftProvider>().error ?? 'Không thể đóng ca làm việc.';
      _showErrorSnackBar(error);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.statusError),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.secondary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final activeShift = shiftProvider.currentShift;

    final isManager =
        currentUser?.roleName == 'Manager' || currentUser?.roleName == 'Admin';
    if (isManager) {
      return _buildManagerShiftView(context);
    }

    return PopScope(
      canPop: activeShift != null,
      child: Scaffold(
        backgroundColor: AppColors.backgroundSlate,
        drawer: widget.onMenuTap == null
            ? const CashierDrawer(selectedTab: CashierNavTab.shift)
            : null,
        appBar: widget.onMenuTap == null
            ? const MiniMartAppBar.primary(title: 'Quản lý ca', showMenu: true)
            : AppBar(
                leading: IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: widget.onMenuTap,
                ),
                title: const Text('Quản lý lịch sử ca'),
                backgroundColor: Colors.white,
              ),
        body: Stack(
          children: [
            if (shiftProvider.error != null && activeShift == null)
              ErrorBanner(
                message: shiftProvider.error!,
                onRetry: () =>
                    context.read<ShiftProvider>().fetchCurrentShift(),
              )
            else
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (activeShift != null) ...[
                        _buildActiveShiftCard(
                          activeShift,
                          currentUser?.fullName ?? 'Nhân viên',
                        ),
                        const SizedBox(height: 16),
                        _buildBentoMetrics(activeShift),
                        const SizedBox(height: 16),
                        _buildCashReconciliation(activeShift),
                        const SizedBox(height: 20),
                        _buildCloseShiftButton(activeShift.shiftId),
                      ] else ...[
                        _buildNoActiveShiftCard(),
                        const SizedBox(height: 16),
                        _buildOpenShiftForm(currentUser?.employeeId ?? 1),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            if (shiftProvider.isLoading || _isProcessing)
              Container(
                color: Colors.black.withValues(alpha: 0.15),
                child: const LoadingOverlay(),
              ),
          ],
        ),
        bottomNavigationBar: widget.onMenuTap == null
            ? const CashierBottomNavigationBar(selectedTab: CashierNavTab.shift)
            : null,
      ),
    );
  }

  Widget _buildActiveShiftCard(Shift shift, String staffName) {
    final diff = DateTime.now().difference(shift.startedAt ?? shift.startTime);
    final duration = diff.isNegative ? Duration.zero : diff;
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final durationStr = "${h}h ${m}m ${s}s";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CA LÀM VIỆC HIỆN TẠI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        FadeTransition(
                          opacity: _pulseController,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Ca đang hoạt động: ${shift.shiftName} (${shift.shiftCode}) [${shift.startTime.hour.toString().padLeft(2, '0')}h - ${shift.endTime.hour.toString().padLeft(2, '0')}h]',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nhân viên',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    staffName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vào ca thực tế',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    shift.startedAt != null
                        ? "${shift.startedAt!.hour.toString().padLeft(2, '0')}:${shift.startedAt!.minute.toString().padLeft(2, '0')} | ${shift.startedAt!.day.toString().padLeft(2, '0')}/${shift.startedAt!.month.toString().padLeft(2, '0')}"
                        : "Chưa nhận ca",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thời gian ca',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        durationStr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'JetBrains Mono',
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveShiftCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.statusError.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.report_gmailerrorred_rounded,
              color: AppColors.statusError,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Không có ca làm việc hoạt động',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Vui lòng mở ca làm việc trước khi thực hiện bán hàng.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenShiftForm(int cashierId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mở ca làm việc mới',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Chọn ca làm việc *',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildShiftTypeButton(0, 'Sáng\n06h - 11h'),
              const SizedBox(width: 8),
              _buildShiftTypeButton(1, 'Chiều\n11h - 16h'),
              const SizedBox(width: 8),
              _buildShiftTypeButton(2, 'Tối\n16h - 22h30'),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _startCashController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Tiền mặt đầu ca (VNĐ) *',
              prefixIcon: Icon(Icons.attach_money_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _openNoteController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Ghi chú mở ca',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _handleOpenShift(cashierId),
            icon: const Icon(Icons.login_rounded),
            label: const Text('Bắt đầu ca làm việc'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoMetrics(Shift shift) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TIỀN MẶT ĐẦU CA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF768DAD),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${_formatCurrency(shift.startCash)} VNĐ",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Doanh thu ghi nhận',
                    style: TextStyle(fontSize: 12, color: Color(0xFF768DAD)),
                  ),
                  Text(
                    "${_formatCurrency(shift.revenue)} VNĐ",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCashReconciliation(Shift shift) {
    if (_endCashInitializedForShiftId != shift.shiftId) {
      final currentCash = shift.startCash + shift.revenue;
      _endCashController.text = currentCash.toInt().toString();
      _endCashInitializedForShiftId = shift.shiftId;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đối soát tiền mặt',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _formatCurrency(shift.startCash),
            readOnly: true,
            style: const TextStyle(color: AppColors.textMuted),
            decoration: const InputDecoration(
              labelText: 'Tiền mặt đầu ca (VNĐ)',
              suffixIcon: Icon(
                Icons.lock_outline_rounded,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _endCashController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Tiền mặt cuối ca (VNĐ) *',
              suffixIcon: Icon(Icons.edit_outlined, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Vui lòng kiểm đếm thực tế và nhập số dư hiện có',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _closeNoteController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Ghi chú đóng ca',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseShiftButton(int shiftId) {
    return FilledButton.icon(
      onPressed: () => _showCloseConfirmationDialog(shiftId),
      icon: const Icon(Icons.logout_rounded),
      label: const Text('Kết thúc ca làm việc'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shadowColor: AppColors.primary.withValues(alpha: 0.2),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showCloseConfirmationDialog(int shiftId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kết thúc ca làm việc?'),
        content: const Text(
          'Hành động này sẽ thực hiện đối soát số dư tiền mặt thực tế và khóa phiên làm việc hiện tại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleCloseShift(shiftId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.statusError,
            ),
            child: const Text('Xác nhận Đóng ca'),
          ),
        ],
      ),
    );
  }

  // --- Manager Shift View Helpers ---
  Widget _buildManagerShiftView(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    final activeShifts = shiftProvider.shifts
        .where((s) => s.status == 2)
        .toList();
    final historicalShifts = shiftProvider.shifts
        .where((s) => s.status != 2)
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundSlate,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: widget.onMenuTap != null
              ? IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: widget.onMenuTap,
                )
              : null,
          title: Text(
            'Quản lý lịch sử ca',
            style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_outline_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Ca hiện tại'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Lịch sử ca'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: shiftProvider.isLoading
            ? const LoadingOverlay()
            : shiftProvider.error != null
            ? ErrorBanner(
                message: shiftProvider.error!,
                onRetry: () => context.read<ShiftProvider>().fetchShifts(),
              )
            : TabBarView(
                children: [
                  _buildShiftTabList(
                    activeShifts,
                    'Không có ca nào đang hoạt động.',
                  ),
                  _buildShiftTabList(
                    historicalShifts,
                    'Không có lịch sử ca làm việc.',
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildShiftTabList(List<Shift> shifts, String emptyMessage) {
    if (shifts.isEmpty) {
      return EmptyState(
        message: emptyMessage,
        icon: Icons.calendar_today_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ShiftProvider>().fetchShifts();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shifts.length,
        itemBuilder: (context, index) {
          final shift = shifts[index];
          return _buildManagerShiftCard(shift);
        },
      ),
    );
  }

  Widget _buildManagerShiftCard(Shift shift) {
    final staffName = _getEmployeeName(shift.employeeId);

    // Status color & badge text
    Color statusBgColor;
    Color statusTextColor;
    String statusLabel;

    switch (shift.status) {
      case 1:
        statusBgColor = AppColors.warningContainer;
        statusTextColor = AppColors.statusWarning;
        statusLabel = 'Chờ duyệt';
        break;
      case 2:
        statusBgColor = const Color(0xE0ECFDF5);
        statusTextColor = AppColors.secondary;
        statusLabel = 'Đang chạy';
        break;
      case 3:
        statusBgColor = const Color(0xE0F1F5F9);
        statusTextColor = AppColors.textMuted;
        statusLabel = 'Đã đóng';
        break;
      case 4:
      default:
        statusBgColor = AppColors.errorContainer;
        statusTextColor = AppColors.statusError;
        statusLabel = 'Đã hủy';
        break;
    }

    final dateStr = DateFormat('dd/MM/yyyy').format(shift.workDate);
    final timeStr =
        "${DateFormat('HH:mm').format(shift.startTime)} - ${DateFormat('HH:mm').format(shift.endTime)}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.shiftName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shift.shiftCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderGray),

          // Details section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCardDetailRow(
                  Icons.person_outline_rounded,
                  'Nhân viên',
                  staffName,
                ),
                const SizedBox(height: 10),
                _buildCardDetailRow(
                  Icons.calendar_today_outlined,
                  'Ngày làm việc',
                  dateStr,
                ),
                const SizedBox(height: 10),
                _buildCardDetailRow(
                  Icons.access_time_rounded,
                  'Giờ hoạt động',
                  timeStr,
                ),
                const SizedBox(height: 10),
                _buildCardDetailRow(
                  Icons.payments_outlined,
                  'Tiền mặt đầu ca',
                  '${_formatCurrency(shift.startCash)} đ',
                ),
                if (shift.status == 3) ...[
                  const SizedBox(height: 10),
                  _buildCardDetailRow(
                    Icons.price_check_rounded,
                    'Tiền mặt cuối ca',
                    '${_formatCurrency(shift.endCash)} đ',
                  ),
                  const SizedBox(height: 10),
                  _buildCardDetailRow(
                    Icons.trending_up_rounded,
                    'Doanh thu ca',
                    '${_formatCurrency(shift.revenue)} đ',
                  ),
                ],
                if (shift.note != null && shift.note!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildCardDetailRow(
                    Icons.notes_rounded,
                    'Ghi chú',
                    shift.note!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _getEmployeeName(int employeeId) {
    final employees = context.read<EmployeeProvider>().employees;
    try {
      final emp = employees.firstWhere((e) => e.employeeId == employeeId);
      return emp.fullName;
    } catch (_) {
      return 'Mã NV: $employeeId';
    }
  }

  Widget _buildShiftTypeButton(int type, String label) {
    final isSelected = _selectedShiftType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedShiftType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondary.withValues(alpha: 0.1)
                : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.borderGray,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.secondary : AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
