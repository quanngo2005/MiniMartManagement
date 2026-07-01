import 'package:flutter/foundation.dart';
import '../models/membership_tier.dart';

class TierProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  final List<MembershipTier> _tiers = [
    MembershipTier(id: '1', name: 'Bronze', requiredPoints: 0, benefits: ['Tích điểm 1% trên mỗi hóa đơn'], colorCode: '#FDE6D2'),
    MembershipTier(id: '2', name: 'Silver', requiredPoints: 500, benefits: ['Tích điểm 2% trên mỗi hóa đơn', 'Quà tặng sinh nhật'], colorCode: '#E2E8F0'),
    MembershipTier(id: '3', name: 'Gold', requiredPoints: 2000, benefits: ['Tích điểm 3% trên mỗi hóa đơn', 'Quà tặng sinh nhật', 'Ưu tiên hỗ trợ'], colorCode: '#FEF3C7'),
  ];

  List<MembershipTier> get tiers => _tiers;

  Future<void> fetchTiers() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }
}
