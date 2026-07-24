import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/category_summary.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/categories/category_action_button.dart';

class CategoryTreeCard extends StatelessWidget {
  const CategoryTreeCard({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final CategorySummary category;
  final ValueChanged<CategorySummary> onEdit;
  final ValueChanged<CategorySummary> onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            _CategoryTreeRow(
              category: category,
              depth: 0,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
            for (final child in category.children) ...[
              const Divider(height: 1, color: AppColors.borderGray),
              _CategoryBranch(
                category: child,
                depth: 1,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryBranch extends StatelessWidget {
  const _CategoryBranch({
    required this.category,
    required this.depth,
    required this.onEdit,
    required this.onDelete,
  });

  final CategorySummary category;
  final int depth;
  final ValueChanged<CategorySummary> onEdit;
  final ValueChanged<CategorySummary> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CategoryTreeRow(
          category: category,
          depth: depth,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
        for (final child in category.children) ...[
          const Divider(height: 1, color: AppColors.borderGray),
          _CategoryBranch(
            category: child,
            depth: depth + 1,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ],
      ],
    );
  }
}

class _CategoryTreeRow extends StatelessWidget {
  const _CategoryTreeRow({
    required this.category,
    required this.depth,
    required this.onEdit,
    required this.onDelete,
  });

  final CategorySummary category;
  final int depth;
  final ValueChanged<CategorySummary> onEdit;
  final ValueChanged<CategorySummary> onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isRoot = depth == 0;

    return Material(
      color: AppColors.surfaceContainerLowest,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.fromLTRB(16 + (depth * 24), 12, 8, 12),
          child: Row(
            children: [
              if (isRoot)
                Icon(category.icon, color: AppColors.primary, size: 24)
              else
                const Icon(
                  Icons.subdirectory_arrow_right_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (isRoot
                                  ? textTheme.titleMedium
                                  : textTheme.bodyMedium)
                              ?.copyWith(
                                color: isRoot
                                    ? AppColors.primary
                                    : AppColors.textDark,
                                fontWeight: isRoot
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _buildMetadata(category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              CategoryActionButton(
                icon: Icons.edit_outlined,
                tooltip: 'Sửa ${category.name}',
                onPressed: () => onEdit(category),
              ),
              CategoryActionButton(
                icon: Icons.delete_outline,
                tooltip: 'Xóa ${category.name}',
                foregroundColor: AppColors.statusError,
                onPressed: () => onDelete(category),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildMetadata(CategorySummary category) {
    final products = '${category.productCount} Sản phẩm';
    if (category.subcategoryCount == 0) return products;

    final suffix = category.subcategoryCount == 1
        ? 'danh mục con'
        : 'danh mục con';
    return '$products - ${category.subcategoryCount} $suffix';
  }
}
