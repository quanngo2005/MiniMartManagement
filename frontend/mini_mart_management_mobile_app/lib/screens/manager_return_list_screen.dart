import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/models/order_return.dart';
import 'package:mini_mart_management_mobile_app/providers/order_return_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/manager_return_detail_screen.dart';
import 'package:provider/provider.dart';

class ManagerReturnListScreen extends StatefulWidget {
  const ManagerReturnListScreen({super.key});

  @override
  State<ManagerReturnListScreen> createState() =>
      _ManagerReturnListScreenState();
}

class _ManagerReturnListScreenState extends State<ManagerReturnListScreen> {
  int _activeFilterTab =
      0; // 0 = Chờ duyệt, 1 = Đã duyệt, 2 = Từ chối, 3 = Tất cả

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderReturnProvider>().loadAllReturns();
    });
  }

  List<OrderReturn> _getFilteredReturns(List<OrderReturn> returns) {
    switch (_activeFilterTab) {
      case 0:
        return returns.where((r) => r.status == 1).toList(); // Pending
      case 1:
        return returns.where((r) => r.status == 2).toList(); // Approved
      case 2:
        return returns.where((r) => r.status == 3).toList(); // Rejected
      default:
        return returns;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderReturnProvider>();
    final isLoading = provider.isLoading;
    final errorMessage = provider.errorMessage;
    final allReturns = provider.allReturns;
    final filteredReturns = _getFilteredReturns(allReturns);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phê duyệt hoàn trả'),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadAllReturns(),
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundSlate,
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? _buildErrorWidget(errorMessage)
                : filteredReturns.isEmpty
                ? _buildEmptyWidget()
                : _buildReturnList(filteredReturns),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = ['Chờ duyệt', 'Đã duyệt', 'Từ chối', 'Tất cả'];
    return Container(
      color: Colors.white,
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _activeFilterTab == index;
          return InkWell(
            onTap: () {
              setState(() {
                _activeFilterTab = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: isSelected
                  ? const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.secondary, width: 3),
                      ),
                    )
                  : null,
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected ? AppColors.secondary : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.statusError,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.statusError,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 12),
          Text(
            'Không có yêu cầu nào',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnList(List<OrderReturn> returns) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: returns.length,
      itemBuilder: (context, index) {
        final r = returns[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ManagerReturnDetailScreen(orderReturn: r),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        r.returnCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      _buildStatusBadge(r.status, r.statusLabel),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Đơn gốc: ${r.originalOrderCode}',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(r.orderDate),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Phân loại: ${r.classifyLabel}',
                        style: TextStyle(
                          color: r.classify == 1
                              ? AppColors.statusError
                              : AppColors.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Hoàn: ${NumberFormat('#,###').format(r.refundAmount)}đ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lý do: ${r.reason}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(int status, String label) {
    Color bg = AppColors.surfaceContainerLow;
    Color fg = AppColors.textMuted;

    if (status == 1) {
      bg = AppColors.warningContainer;
      fg = AppColors.statusWarning;
    } else if (status == 2) {
      bg = AppColors.secondaryContainer;
      fg = AppColors.secondary;
    } else if (status == 3) {
      bg = AppColors.errorContainer;
      fg = AppColors.statusError;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
