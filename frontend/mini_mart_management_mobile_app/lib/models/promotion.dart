enum PromotionLifecycleStatus { active, upcoming, ended, inactive }

class Promotion {
  final int promotionId;
  final String name;
  final String description;
  final int type; // 0 = PercentDiscount, 1 = BuyXGetYFree, 2 = ProductDiscount
  final double? discountPercent;
  final double? discountAmount;
  final double? minimumOrderAmount;
  final int? buyQuantity;
  final int? giftQuantity;
  final int? giftProductId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<int> productIds;

  const Promotion({
    required this.promotionId,
    required this.name,
    required this.description,
    required this.type,
    this.discountPercent,
    this.discountAmount,
    this.minimumOrderAmount,
    this.buyQuantity,
    this.giftQuantity,
    this.giftProductId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.productIds,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    final rawProductIds =
        json['productIds'] ?? json['ProductIds'] ?? <dynamic>[];
    final parsedIds = (rawProductIds as List).map((e) => e as int).toList();

    return Promotion(
      promotionId: (json['promotionId'] ?? json['PromotionId'] ?? 0) as int,
      name: (json['name'] ?? json['Name'] ?? '') as String,
      description: (json['description'] ?? json['Description'] ?? '') as String,
      type: (json['type'] ?? json['Type'] ?? 0) as int,
      discountPercent: (json['discountPercent'] ?? json['DiscountPercent'])
          ?.toDouble(),
      discountAmount: (json['discountAmount'] ?? json['DiscountAmount'])
          ?.toDouble(),
      minimumOrderAmount:
          (json['minimumOrderAmount'] ?? json['MinimumOrderAmount'])
              ?.toDouble(),
      buyQuantity: (json['buyQuantity'] ?? json['BuyQuantity']) as int?,
      giftQuantity: (json['giftQuantity'] ?? json['GiftQuantity']) as int?,
      giftProductId: (json['giftProductId'] ?? json['GiftProductId']) as int?,
      startDate: DateTime.parse(
        (json['startDate'] ?? json['StartDate']) as String,
      ),
      endDate: DateTime.parse((json['endDate'] ?? json['EndDate']) as String),
      isActive: (json['isActive'] ?? json['IsActive'] ?? false) as bool,
      productIds: parsedIds,
    );
  }

  // Convenience getters cho UI code cũ
  String get id => promotionId.toString();
  String get title => name;
  // Backend không có field 'code' — hiển thị id như placeholder
  String get code => 'KM$promotionId';
  PromotionLifecycleStatus get lifecycleStatus {
    final now = DateTime.now();
    if (!isActive) return PromotionLifecycleStatus.inactive;
    if (now.isBefore(startDate)) return PromotionLifecycleStatus.upcoming;
    if (now.isAfter(endDate)) return PromotionLifecycleStatus.ended;
    return PromotionLifecycleStatus.active;
  }

  String get status {
    final now = DateTime.now();
    if (!isActive) return 'Ngưng';
    if (now.isBefore(startDate)) return 'Sắp diễn ra';
    if (now.isAfter(endDate)) return 'Đã kết thúc';
    return 'Đang chạy';
  }

  String get discountType {
    switch (type) {
      case 0:
        return 'Phần trăm';
      case 1:
        return 'Mua X tặng Y';
      default:
        return 'Giảm sản phẩm';
    }
  }

  double get discountValue => discountPercent ?? discountAmount ?? 0;
  double get minPurchaseAmount => minimumOrderAmount ?? 0;
}
