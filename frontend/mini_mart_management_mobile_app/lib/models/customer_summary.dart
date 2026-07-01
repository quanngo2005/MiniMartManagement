class CustomerSummary {
  final int customerId;
  final String customerCode;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final int points;
  final bool customerStatus;

  const CustomerSummary({
    required this.customerId,
    required this.customerCode,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.points,
    required this.customerStatus,
  });

  factory CustomerSummary.fromJson(Map<String, dynamic> json) {
    return CustomerSummary(
      customerId: (json['customerId'] ?? json['CustomerId'] ?? 0) as int,
      customerCode: (json['customerCode'] ?? json['CustomerCode'] ?? '') as String,
      name: (json['fullName'] ?? json['FullName'] ?? '') as String,
      phone: (json['phoneNumber'] ?? json['PhoneNumber'] ?? '') as String,
      email: json['email'] as String? ?? json['Email'] as String?,
      address: json['address'] as String? ?? json['Address'] as String?,
      points: (json['point'] ?? json['Point'] ?? 0) as int,
      customerStatus: (json['customerStatus'] ?? json['CustomerStatus'] ?? false) as bool,
    );
  }

  // Convenience getter — screens dùng customer.id (String) để navigate
  String get id => customerId.toString();

  // Screens dùng customer.tier để hiển thị TierBadge — giữ placeholder
  String get tier => '';
}
