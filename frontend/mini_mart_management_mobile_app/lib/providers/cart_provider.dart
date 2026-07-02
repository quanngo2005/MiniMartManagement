import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/models/cart_item.dart';
import 'package:mini_mart_management_mobile_app/models/product_lookup.dart';


class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  int? _selectedCustomerId;
  String? _selectedCustomerName;
  int? _selectedCustomerPoints;
  int _paymentMethod = 1; // 1 = Cash, 3 = EWallet (VNPAY)

  List<CartItem> get items => _items;
  int? get selectedCustomerId => _selectedCustomerId;
  String? get selectedCustomerName => _selectedCustomerName;
  int? get selectedCustomerPoints => _selectedCustomerPoints;
  int get paymentMethod => _paymentMethod;

  double get totalAmount {
    double total = 0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  void addItem(ProductLookup product) {
    final index = _items.indexWhere((i) => i.product.productId == product.productId);
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

  void setCustomer(int id, String name, int points) {
    _selectedCustomerId = id;
    _selectedCustomerName = name;
    _selectedCustomerPoints = points;
    notifyListeners();
  }

  void clearCustomer() {
    _selectedCustomerId = null;
    _selectedCustomerName = null;
    _selectedCustomerPoints = null;
    notifyListeners();
  }

  void setPaymentMethod(int method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    clearCustomer();
    _paymentMethod = 1;
    notifyListeners();
  }
}
