import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/promotion_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/promotions/promotion_card.dart';

class PromotionManagementScreen extends StatefulWidget {
  const PromotionManagementScreen({super.key});

  @override
  State<PromotionManagementScreen> createState() => _PromotionManagementScreenState();
}

class _PromotionManagementScreenState extends State<PromotionManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromotionProvider>().fetchPromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý khuyến mãi'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
      ),
      body: Consumer<PromotionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.promotions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return PromotionCard(
                promotion: provider.promotions[index],
                onTap: () {},
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceContainerLowest,
        child: const Icon(Icons.add),
      ),
    );
  }
}
