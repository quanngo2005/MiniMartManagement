import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/promotion.dart';
import 'package:mini_mart_management_mobile_app/services/promotion_service.dart';

class PromotionRepository {
  const PromotionRepository(this._promotionService);

  final PromotionService _promotionService;

  Future<List<Promotion>> getAllPromotions() async {
    try {
      return await _promotionService.getAllPromotions();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải danh sách khuyến mãi: ${e.toString()}');
    }
  }

  Future<Promotion> getPromotionById(int id) async {
    try {
      return await _promotionService.getPromotionById(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tải thông tin khuyến mãi: ${e.toString()}');
    }
  }

  Future<Promotion> createPromotion(Map<String, dynamic> data) async {
    try {
      return await _promotionService.createPromotion(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể tạo khuyến mãi: ${e.toString()}');
    }
  }

  Future<Promotion> updatePromotion(int id, Map<String, dynamic> data) async {
    try {
      return await _promotionService.updatePromotion(id, data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể cập nhật khuyến mãi: ${e.toString()}');
    }
  }

  Future<void> deletePromotion(int id) async {
    try {
      await _promotionService.deletePromotion(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể xóa khuyến mãi: ${e.toString()}');
    }
  }
}
