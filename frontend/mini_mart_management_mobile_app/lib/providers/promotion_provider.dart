import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/promotion.dart';
import 'package:mini_mart_management_mobile_app/repositories/promotion_repository.dart';

class PromotionProvider with ChangeNotifier {
  PromotionProvider(this._promotionRepository);

  final PromotionRepository _promotionRepository;

  List<Promotion> _promotions = [];
  bool _isLoading = false;
  String? _error;

  List<Promotion> get promotions => _promotions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPromotions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _promotions = await _promotionRepository.getAllPromotions();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Đã xảy ra lỗi khi tải danh sách khuyến mãi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPromotion(Map<String, dynamic> data) async {
    try {
      final created = await _promotionRepository.createPromotion(data);
      _promotions = [..._promotions, created];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePromotion(int id, Map<String, dynamic> data) async {
    try {
      final updated = await _promotionRepository.updatePromotion(id, data);
      _promotions = _promotions
          .map((p) => p.promotionId == id ? updated : p)
          .toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePromotion(int id) async {
    try {
      await _promotionRepository.deletePromotion(id);
      _promotions = _promotions.where((p) => p.promotionId != id).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
