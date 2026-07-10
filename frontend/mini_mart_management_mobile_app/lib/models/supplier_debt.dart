class SupplierDebt {
  const SupplierDebt({
    required this.supplierId,
    required this.supplierName,
    required this.totalDebt,
  });

  final int supplierId;
  final String supplierName;
  final double totalDebt;

  factory SupplierDebt.fromJson(Map<String, dynamic> json) {
    return SupplierDebt(
      supplierId: json['supplierId'] ?? json['SupplierId'] ?? 0,
      supplierName: json['supplierName'] ?? json['SupplierName'] ?? '',
      totalDebt: (json['totalDebt'] ?? json['TotalDebt'] ?? 0.0).toDouble(),
    );
  }
}
