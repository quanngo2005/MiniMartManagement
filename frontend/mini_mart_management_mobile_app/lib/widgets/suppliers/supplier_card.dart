import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/supplier.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class SupplierCard extends StatelessWidget {
  const SupplierCard({
    super.key,
    required this.supplier,
    required this.onEdit,
    required this.onDelete,
  });

  final Supplier supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.business_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.supplierName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      supplier.supplierCode,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(active: supplier.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          if (supplier.contactPerson != null) ...[
            _InfoRow(
              icon: Icons.person_outline_rounded,
              text: supplier.contactPerson!,
            ),
            const SizedBox(height: 6),
          ],
          _InfoRow(icon: Icons.call_outlined, text: supplier.phoneNumber),
          if (supplier.email != null) ...[
            const SizedBox(height: 6),
            _InfoRow(icon: Icons.mail_outline_rounded, text: supplier.email!),
          ],
          if (supplier.address != null) ...[
            const SizedBox(height: 6),
            _InfoRow(icon: Icons.location_on_outlined, text: supplier.address!),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Sửa'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Xóa'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.statusError,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        active ? 'Hoạt động' : 'Ngừng hợp tác',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: active ? const Color(0xFF15803D) : AppColors.statusError,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}
