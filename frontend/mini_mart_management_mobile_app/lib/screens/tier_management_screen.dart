import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tier_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/tiers/tier_info_card.dart';

class TierManagementScreen extends StatefulWidget {
  const TierManagementScreen({super.key});

  @override
  State<TierManagementScreen> createState() => _TierManagementScreenState();
}

class _TierManagementScreenState extends State<TierManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TierProvider>().fetchTiers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hạng thành viên'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
      ),
      body: Consumer<TierProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.tiers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return TierInfoCard(
                tier: provider.tiers[index],
                onEdit: () {},
              );
            },
          );
        },
      ),
    );
  }
}
