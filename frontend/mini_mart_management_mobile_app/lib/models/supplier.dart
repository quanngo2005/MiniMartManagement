class Supplier {
  const Supplier({
    required this.supplierId,
    required this.supplierCode,
    required this.supplierName,
<<<<<<< HEAD
    required this.phoneNumber,
    required this.status,
    this.contactPerson,
=======
    this.contactPerson,
    required this.phoneNumber,
    this.email,
    this.address,
    this.taxCode,
    this.bankAccount,
    this.bankName,
    this.description,
    required this.status,
>>>>>>> kiet_dev
  });

  final int supplierId;
  final String supplierCode;
  final String supplierName;
<<<<<<< HEAD
  final String phoneNumber;
  final bool status;
  final String? contactPerson;
=======
  final String? contactPerson;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String? taxCode;
  final String? bankAccount;
  final String? bankName;
  final String? description;
  final bool status;
>>>>>>> kiet_dev

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      supplierId: _readInt(json, 'supplierId', 'SupplierId'),
      supplierCode: _readString(json, 'supplierCode', 'SupplierCode'),
      supplierName: _readString(json, 'supplierName', 'SupplierName'),
<<<<<<< HEAD
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
=======
      contactPerson: _readNullableString(json, 'contactPerson', 'ContactPerson'),
      phoneNumber: _readString(json, 'phoneNumber', 'PhoneNumber'),
      email: _readNullableString(json, 'email', 'Email'),
      address: _readNullableString(json, 'address', 'Address'),
      taxCode: _readNullableString(json, 'taxCode', 'TaxCode'),
      bankAccount: _readNullableString(json, 'bankAccount', 'BankAccount'),
      bankName: _readNullableString(json, 'bankName', 'BankName'),
      description: _readNullableString(json, 'description', 'Description'),
      status: _readBool(json, 'status', 'Status'),
    );
  }

  Map<String, dynamic> toJson() => {
        'supplierId': supplierId,
        'supplierCode': supplierCode,
        'supplierName': supplierName,
        'contactPerson': contactPerson,
        'phoneNumber': phoneNumber,
        'email': email,
        'address': address,
        'taxCode': taxCode,
        'bankAccount': bankAccount,
        'bankName': bankName,
        'description': description,
        'status': status,
      };

  static int _readInt(Map<String, dynamic> json, String c, String p) {
    final v = json[c] ?? json[p];
    if (v is int) return v;
    if (v is num) return v.toInt();
    throw FormatException('Invalid $c.');
  }

  static String _readString(Map<String, dynamic> json, String c, String p) {
    final v = json[c] ?? json[p];
    if (v is String) return v;
    throw FormatException('Invalid $c.');
  }

  static bool _readBool(Map<String, dynamic> json, String c, String p) {
    final v = json[c] ?? json[p];
    if (v is bool) return v;
    throw FormatException('Invalid $c.');
  }

  static String? _readNullableString(Map<String, dynamic> json, String c, String p) {
    final v = json[c] ?? json[p];
    if (v == null || v is String) return v as String?;
    throw FormatException('Invalid $c.');
  }
>>>>>>> kiet_dev
}
