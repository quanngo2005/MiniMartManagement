import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/product_lookup.dart';
import 'package:mini_mart_management_mobile_app/models/supplier.dart';
import 'package:mini_mart_management_mobile_app/services/inventory_lookup_service.dart';

class InventoryLookupRepository {
  const InventoryLookupRepository(this._lookupService);

  final InventoryLookupService _lookupService;

  Future<ProductLookup?> fetchProductByBarcode(String barcode) async {
    try {
      return await _lookupService.fetchProductByBarcode(barcode);
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Không thể đọc thông tin sản phẩm.');
    }
  }

  Future<List<ProductLookup>> fetchProducts() async {
    try {
      return await _lookupService.fetchProducts();
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Không thể đọc danh sách sản phẩm.');
    }
  }

  Future<List<Supplier>> fetchSuppliers() async {
    try {
      return await _lookupService.fetchSuppliers();
    } on ApiException {
      return _fallbackSuppliers;
    } on FormatException {
      return _fallbackSuppliers;
    }
  }

  static const List<Supplier> _fallbackSuppliers = [
    Supplier(
      supplierId: 1,
      supplierCode: 'NCC-001',
      supplierName: 'Công ty Minh Long',
      phoneNumber: '0901 234 567',
      status: true,
      contactPerson: 'Minh Long',
    ),
    Supplier(
      supplierId: 2,
      supplierCode: 'NCC-002',
      supplierName: 'Minh Tâm Food',
      phoneNumber: '0908 555 123',
      status: true,
      contactPerson: 'Minh Tâm',
    ),
  ];
}
