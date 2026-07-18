import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_mart_management_mobile_app/models/shift.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/shift_provider.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
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
  bool _isProcessing = false;
  bool _selectedIsMorning = true;

  @override
  void initState() {
    super.initState();
    final hour = DateTime.now().hour;
    _selectedIsMorning = hour >= 6 && hour < 14;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShiftProvider>().fetchCurrentShift();
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
      isMorning: _selectedIsMorning,
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

    return PopScope(
      canPop: activeShift != null,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: activeShift != null,
          leading: widget.onMenuTap != null
              ? IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: widget.onMenuTap,
                )
              : null,
          title: Row(
            children: [
              if (widget.onMenuTap == null) ...[
                const Icon(Icons.storefront_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  'Store #402 | Quản lý ca',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: AppColors.borderGray, height: 1),
          ),
        ),
        body: Stack(
          children: [
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
                      const SizedBox(height: 16),
                      _buildSparklineChart(),
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
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
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
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedIsMorning = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedIsMorning
                          ? AppColors.secondary.withValues(alpha: 0.1)
                          : Colors.white,
                      border: Border.all(
                        color: _selectedIsMorning
                            ? AppColors.secondary
                            : AppColors.borderGray,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Ca sáng (06h - 14h)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _selectedIsMorning
                              ? AppColors.secondary
                              : AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedIsMorning = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_selectedIsMorning
                          ? AppColors.secondary.withValues(alpha: 0.1)
                          : Colors.white,
                      border: Border.all(
                        color: !_selectedIsMorning
                            ? AppColors.secondary
                            : AppColors.borderGray,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Ca chiều (14h - 22h)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: !_selectedIsMorning
                              ? AppColors.secondary
                              : AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
    final currentCash = shift.startCash + shift.revenue;
    final expectedEndCash = currentCash;

    return Column(
      children: [
        // Cash Card
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
                'TIỀN MẶT HIỆN TẠI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF768DAD),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${_formatCurrency(currentCash)} VNĐ",
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
                    'Dự kiến kết ca',
                    style: TextStyle(fontSize: 12, color: Color(0xFF768DAD)),
                  ),
                  Text(
                    "${_formatCurrency(expectedEndCash)} VNĐ",
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
        const SizedBox(height: 12),
        // Bento stats row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGray),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giao dịch',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '142',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGray),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tốc độ phục vụ',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.speed_rounded,
                          color: AppColors.statusWarning,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '1.2m',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCashReconciliation(Shift shift) {
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

  Widget _buildSparklineChart() {
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DOANH THU THEO GIỜ',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                '+12% vs Hôm qua',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(0.40, AppColors.surface),
                _buildBar(0.55, AppColors.surface),
                _buildBar(0.35, AppColors.surface),
                _buildBar(0.70, AppColors.surface),
                _buildBar(0.90, AppColors.surface),
                _buildBar(1.00, AppColors.primary),
                _buildBar(0.80, AppColors.secondary),
                _buildBar(0.60, AppColors.surface),
                _buildBar(0.45, AppColors.surface),
                _buildBar(0.30, AppColors.surface),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: FractionallySizedBox(
          heightFactor: heightFactor,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(2),
              ),
            ),
          ),
        ),
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
}
