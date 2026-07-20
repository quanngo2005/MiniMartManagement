import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/membership_tier.dart';
import '../providers/tier_provider.dart';
import '../theme/app_colors.dart';

class TierDetailScreen extends StatefulWidget {
  const TierDetailScreen({super.key, required this.tierId});

  final String tierId;

  @override
  State<TierDetailScreen> createState() => _TierDetailScreenState();
}

class _TierDetailScreenState extends State<TierDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pointsController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _colorController = TextEditingController();

  bool _isSaving = false;
  String? _loadedTierId;

  @override
  void dispose() {
    _pointsController.dispose();
    _benefitsController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _syncForm(MembershipTier tier) {
    if (_loadedTierId == tier.id) return;
    _loadedTierId = tier.id;
    _pointsController.text = tier.requiredPoints.toString();
    _benefitsController.text = tier.benefits.join('\n');
    _colorController.text = tier.colorCode;
  }

  Future<void> _save(MembershipTier tier) async {
    if (!_formKey.currentState!.validate()) return;

    final benefits = _benefitsController.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    setState(() => _isSaving = true);
    final provider = context.read<TierProvider>();
    final ok = await provider.updateTier(
      tierId: tier.id,
      requiredPoints: int.parse(_pointsController.text.trim()),
      benefits: benefits,
      colorCode: _colorController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Đã lưu cấu hình ${tier.name}.' : provider.error ?? 'Không thể lưu cấu hình loyalty.',
        ),
        backgroundColor: ok ? AppColors.secondary : AppColors.statusError,
      ),
    );

    if (ok) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tier = context.select<TierProvider, MembershipTier?>(
      (provider) => provider.tierById(widget.tierId),
    );

    if (tier == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết loyalty')),
        body: const Center(child: Text('Không tìm thấy hạng loyalty.')),
      );
    }

    _syncForm(tier);
    final color = _parseColor(tier.colorCode);

    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: Text('Chi tiết ${tier.name}'),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : () => _save(tier),
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGray),
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: color, radius: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                        Text(
                          '${NumberFormat('#,###').format(tier.requiredPoints)} điểm trở lên',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Ngưỡng điểm',
                helperText: 'Bronze 0, Silver 500, Gold 1000',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final points = int.tryParse(value?.trim() ?? '');
                if (points == null || points < 0) {
                  return 'Nhập ngưỡng điểm hợp lệ.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Mã màu',
                helperText: 'Ví dụ: #FFD700',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final colorCode = value?.trim() ?? '';
                final valid = RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(colorCode);
                return valid ? null : 'Mã màu phải có dạng #RRGGBB.';
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _benefitsController,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Quyền lợi',
                helperText: 'Mỗi dòng là một quyền lợi',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final hasBenefit = (value ?? '')
                    .split('\n')
                    .any((line) => line.trim().isNotEmpty);
                return hasBenefit ? null : 'Nhập ít nhất một quyền lợi.';
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isSaving ? null : () => _save(tier),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Lưu cấu hình'),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorCode) {
    final valid = RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(colorCode);
    if (!valid) return AppColors.primary;
    return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
  }
}
