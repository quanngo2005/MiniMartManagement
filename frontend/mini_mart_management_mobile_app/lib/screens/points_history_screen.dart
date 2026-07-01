import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../theme/app_colors.dart';

class PointsHistoryScreen extends StatefulWidget {
  const PointsHistoryScreen({super.key, required this.customerId});
  final String customerId;

  @override
  State<PointsHistoryScreen> createState() => _PointsHistoryScreenState();
}

class _PointsHistoryScreenState extends State<PointsHistoryScreen> {
  int? _currentPoints;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final id = int.tryParse(widget.customerId);
    if (id == null) {
      setState(() {
        _error = 'ID không hợp lệ.';
        _isLoading = false;
      });
      return;
    }
    final points =
        await context.read<CustomerProvider>().fetchCustomerPoints(id);
    setState(() {
      _currentPoints = points;
      _error = points == null ? 'Không thể tải điểm.' : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điểm tích lũy'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars, color: AppColors.secondary, size: 64),
          const SizedBox(height: 16),
          Text(
            NumberFormat('#,###').format(_currentPoints ?? 0),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'điểm tích lũy',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
