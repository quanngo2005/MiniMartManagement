import 'package:flutter/foundation.dart';
import '../models/membership_tier.dart';

class TierProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<MembershipTier> _tiers = const [
    MembershipTier(
      id: '3',
      name: 'Gold',
      requiredPoints: 1000,
      benefits: ['Giảm giá 10%', 'Miễn phí vận chuyển', 'Quà tặng sinh nhật'],
      colorCode: '#FFD700',
    ),
    MembershipTier(
      id: '2',
      name: 'Silver',
      requiredPoints: 500,
      benefits: ['Giảm giá 5%', 'Giao hàng ưu tiên'],
      colorCode: '#C0C0C0',
    ),
    MembershipTier(
      id: '1',
      name: 'Bronze',
      requiredPoints: 0,
      benefits: ['Giảm giá 2%'],
      colorCode: '#CD7F32',
    ),
  ];

  List<MembershipTier> get tiers => _tiers;
  MembershipTier? tierById(String tierId) {
    for (final tier in _tiers) {
      if (tier.id == tierId) return tier;
    }
    return null;
  }

  Future<void> fetchTiers() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateTier({
    required String tierId,
    required int requiredPoints,
    required List<String> benefits,
    required String colorCode,
  }) async {
    _error = null;
    if (requiredPoints < 0) {
      _error = 'Ngưỡng điểm không hợp lệ.';
      notifyListeners();
      return false;
    }

    if (!colorCode.startsWith('#') || colorCode.length != 7) {
      _error = 'Mã màu phải có dạng #RRGGBB.';
      notifyListeners();
      return false;
    }

    if (tierById(tierId) == null) {
      _error = 'Không tìm thấy hạng loyalty.';
      notifyListeners();
      return false;
    }

    _tiers =
        _tiers
            .map((tier) {
              if (tier.id != tierId) return tier;
              return tier.copyWith(
                requiredPoints: requiredPoints,
                benefits: benefits,
                colorCode: colorCode,
              );
            })
            .toList(growable: false)
          ..sort((a, b) => b.requiredPoints.compareTo(a.requiredPoints));
    notifyListeners();
    return true;
  }
}
