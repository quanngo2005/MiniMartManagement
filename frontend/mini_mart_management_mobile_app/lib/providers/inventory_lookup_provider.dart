import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/product_lookup.dart';
import 'package:mini_mart_management_mobile_app/models/supplier.dart';
import 'package:mini_mart_management_mobile_app/repositories/inventory_lookup_repository.dart';

class InventoryLookupProvider extends ChangeNotifier {
  InventoryLookupProvider(this._lookupRepository);

  final InventoryLookupRepository _lookupRepository;

  List<ProductLookup> _products = const [];
  List<Supplier> _suppliers = const [];
  String? _errorMessage;
  bool _isLoading = false;
  bool _isScanning = false;

  List<ProductLookup> get products => _products;
  List<Supplier> get suppliers => _suppliers;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;

  Future<ProductLookup?> fetchProductByBarcode(String barcode) async {
    _isScanning = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final product = await _lookupRepository.fetchProductByBarcode(barcode);
      return product;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (_) {
      _errorMessage = 'Không thể tìm kiếm sản phẩm.';
      return null;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> loadLookups() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final products = await _lookupRepository.fetchProducts();
      final suppliers = await _lookupRepository.fetchSuppliers();
      _products = products;
      _suppliers = suppliers;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Không thể tải dữ liệu nhập hàng.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
