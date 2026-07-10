import 'package:flutter/foundation.dart';
import '../models/membership_tier.dart';

class TierProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  final List<MembershipTier> _tiers = const [
    MembershipTier(
      id: '3',
      name: 'Gold',
      requiredPoints: 10000,
      benefits: ['Giảm giá 10%', 'Miễn phí vận chuyển', 'Quà tặng sinh nhật'],
      colorCode: '#FFD700',
    ),
    MembershipTier(
      id: '2',
      name: 'Silver',
      requiredPoints: 5000,
      benefits: ['Giảm giá 5%', 'Giao hàng ưu tiên'],
      colorCode: '#C0C0C0',
    ),
    MembershipTier(
      id: '1',
      name: 'Bronze',
      requiredPoints: 1000,
      benefits: ['Giảm giá 2%'],
      colorCode: '#CD7F32',
    ),
  ];

  List<MembershipTier> get tiers => _tiers;

  Future<void> fetchTiers() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoading = false;
    notifyListeners();
  }
}
