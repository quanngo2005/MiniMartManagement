import 'package:mini_mart_management_mobile_app/models/product_lookup.dart';

class CartItem {
  CartItem({
    required this.product,
    this.quantity = 1,
  });

  final ProductLookup product;
  int quantity;

  double get totalPrice => product.sellingPrice * quantity;
}
