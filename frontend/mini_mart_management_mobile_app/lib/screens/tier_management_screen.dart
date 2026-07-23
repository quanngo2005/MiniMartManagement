import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tier_provider.dart';
import '../screens/tier_detail_screen.dart';
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
        title: const Text('Cấu hình loyalty'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
      ),
      body: Consumer<TierProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.tiers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final tier = provider.tiers[index];
              return TierInfoCard(
                tier: tier,
                onTap: () => _openTierDetail(context, tier.id),
                onEdit: () => _openTierDetail(context, tier.id),
              );
            },
          );
        },
      ),
    );
  }

  void _openTierDetail(BuildContext context, String tierId) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TierDetailScreen(tierId: tierId)));
  }
}
