class Supplier {
  const Supplier({
    required this.supplierId,
    required this.supplierCode,
    required this.supplierName,
    required this.phoneNumber,
    required this.status,
    this.contactPerson,
  });

  final int supplierId;
  final String supplierCode;
  final String supplierName;
  final String phoneNumber;
  final bool status;
  final String? contactPerson;

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      supplierId: _readInt(json, 'supplierId', 'SupplierId'),
      supplierCode: _readString(json, 'supplierCode', 'SupplierCode'),
      supplierName: _readString(json, 'supplierName', 'SupplierName'),
      phoneNumber: _readString(json, 'phoneNumber', 'PhoneNumber'),
      status: _readBool(json, 'status', 'Status'),
      contactPerson: _readNullableString(json, 'contactPerson', 'ContactPerson'),
    );
  }
}

int _readInt(Map<String, dynamic> json, String camelKey, String pascalKey) {
  final value = json[camelKey] ?? json[pascalKey];
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('Invalid $camelKey.');
}

String _readString(Map<String, dynamic> json, String camelKey, String pascalKey) {
  final value = json[camelKey] ?? json[pascalKey];
  if (value is String) return value;
  throw FormatException('Invalid $camelKey.');
}

String? _readNullableString(
  Map<String, dynamic> json,
  String camelKey,
  String pascalKey,
) {
  final value = json[camelKey] ?? json[pascalKey];
  if (value == null || value is String) return value;
  throw FormatException('Invalid $camelKey.');
}

bool _readBool(Map<String, dynamic> json, String camelKey, String pascalKey) {
  final value = json[camelKey] ?? json[pascalKey];
  if (value is bool) return value;
  throw FormatException('Invalid $camelKey.');
}
