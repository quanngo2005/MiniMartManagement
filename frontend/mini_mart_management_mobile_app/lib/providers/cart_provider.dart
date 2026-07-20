import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/models/cart_item.dart';
import 'package:mini_mart_management_mobile_app/models/product_lookup.dart';
import 'package:mini_mart_management_mobile_app/models/promotion.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  int? _selectedCustomerId;
  String? _selectedCustomerName;
  int? _selectedCustomerPoints;
  int _paymentMethod = 1; // 1 = Cash, 3 = EWallet (VNPAY)
  int _pointsToUse = 0;
  bool _useLoyaltyPoints = false;
  List<Promotion> _promotions = [];

  List<CartItem> get items => _items;
  int? get selectedCustomerId => _selectedCustomerId;
  String? get selectedCustomerName => _selectedCustomerName;
  int? get selectedCustomerPoints => _selectedCustomerPoints;
  int get paymentMethod => _paymentMethod;
  int get pointsToUse => _pointsToUse;
  bool get useLoyaltyPoints => _useLoyaltyPoints;
  List<Promotion> get promotions => List.unmodifiable(_promotions);

  double get totalAmount {
    double total = 0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  double get loyaltyDiscountAmount {
    return _useLoyaltyPoints ? _pointsToUse * 1000.0 : 0;
  }

  double get promotionDiscountAmount {
    final activePromotions = _activePromotions;
    final productDiscount = _productDiscountAmount(activePromotions);
    final orderDiscount = _orderDiscountAmount(activePromotions, productDiscount);
    return productDiscount + orderDiscount;
  }

  double get discountAmount {
    return loyaltyDiscountAmount + promotionDiscountAmount;
  }

  double get finalAmount {
    double finalAmt = totalAmount - discountAmount;
    return finalAmt < 0 ? 0 : finalAmt;
  }

  int get maxPointsCanUse {
    if (_selectedCustomerPoints == null) return 0;
    int maxFromTotal =
        ((totalAmount - promotionDiscountAmount).clamp(0, double.infinity) /
                1000)
            .floor();
    return _selectedCustomerPoints! < maxFromTotal
        ? _selectedCustomerPoints!
        : maxFromTotal;
  }

  int giftQuantityForProduct(int productId) {
    final item = _items.where((i) => i.product.productId == productId).firstOrNull;
    if (item == null) return 0;

    final promotion = _activePromotions
        .where(
          (p) =>
              p.type == 1 &&
              (p.buyQuantity ?? 0) > 0 &&
              (p.giftQuantity ?? 0) > 0 &&
              p.productIds.contains(productId),
        )
        .toList()
      ..sort((a, b) {
        final giftCompare = (b.giftQuantity ?? 0).compareTo(a.giftQuantity ?? 0);
        return giftCompare != 0
            ? giftCompare
            : a.promotionId.compareTo(b.promotionId);
      });

    if (promotion.isEmpty) return 0;
    final selected = promotion.first;
    return (item.quantity ~/ selected.buyQuantity!) * selected.giftQuantity!;
  }

  void setPointsToUse(int points) {
    if (points < 0) points = 0;
    if (points > maxPointsCanUse) points = maxPointsCanUse;
    _pointsToUse = points;
    _useLoyaltyPoints = _pointsToUse > 0;
    notifyListeners();
  }

  void setUseLoyaltyPoints(bool value) {
    _useLoyaltyPoints = value;
    _pointsToUse = value ? maxPointsCanUse : 0;
    notifyListeners();
  }

  void addItem(ProductLookup product) {
    final index = _items.indexWhere(
      (i) => i.product.productId == product.productId,
    );
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void updateQuantity(int productId, int delta) {
    final index = _items.indexWhere((i) => i.product.productId == productId);
    if (index >= 0) {
      final newQuantity = _items[index].quantity + delta;
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void setQuantity(int productId, int quantity) {
    final index = _items.indexWhere((i) => i.product.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void setCustomer(int id, String name, int points) {
    _selectedCustomerId = id;
    _selectedCustomerName = name;
    _selectedCustomerPoints = points;
    _useLoyaltyPoints = false;
    _pointsToUse = 0;
    notifyListeners();
  }

  void clearCustomer() {
    _selectedCustomerId = null;
    _selectedCustomerName = null;
    _selectedCustomerPoints = null;
    _pointsToUse = 0;
    _useLoyaltyPoints = false;
    notifyListeners();
  }

  void setPaymentMethod(int method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setPromotions(List<Promotion> promotions) {
    _promotions = promotions;
    if (_pointsToUse > maxPointsCanUse) {
      _pointsToUse = maxPointsCanUse;
    }
    if (_pointsToUse == 0) {
      _useLoyaltyPoints = false;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    clearCustomer();
    _paymentMethod = 1;
    notifyListeners();
  }

  List<Promotion> get _activePromotions {
    final now = DateTime.now();
    return _promotions
        .where(
          (p) =>
              p.isActive &&
              !now.isBefore(p.startDate) &&
              !now.isAfter(p.endDate),
        )
        .toList(growable: false);
  }

  double _productDiscountAmount(List<Promotion> activePromotions) {
    var totalDiscount = 0.0;
    for (final item in _items) {
      final discounts = activePromotions
          .where((p) => p.type == 2 && p.productIds.contains(item.product.productId))
          .map((p) {
        final lineTotal = item.totalPrice;
        if (p.discountPercent != null) {
          return lineTotal * p.discountPercent! / 100;
        }
        return (p.discountAmount ?? 0) * item.quantity;
      }).where((amount) => amount > 0).toList()
        ..sort((a, b) => b.compareTo(a));

      if (discounts.isNotEmpty) {
        totalDiscount += discounts.first.clamp(0, item.totalPrice);
      }
    }
    return totalDiscount;
  }

  double _orderDiscountAmount(
    List<Promotion> activePromotions,
    double productDiscount,
  ) {
    final eligibleDiscounts = activePromotions
        .where(
          (p) =>
              p.type == 0 &&
              totalAmount >= (p.minimumOrderAmount ?? 0),
        )
        .map((p) {
      if (p.discountPercent != null) {
        return (totalAmount - productDiscount) * p.discountPercent! / 100;
      }
      return p.discountAmount ?? 0;
    }).where((amount) => amount > 0).toList()
      ..sort((a, b) => b.compareTo(a));

    return eligibleDiscounts.isEmpty ? 0 : eligibleDiscounts.first;
  }
}
