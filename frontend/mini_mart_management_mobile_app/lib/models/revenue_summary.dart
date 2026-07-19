class RevenueSummary {
  const RevenueSummary({
    required this.totalRevenue,
    required this.totalOrders,
    this.startDate,
    this.endDate,
  });

  final double totalRevenue;
  final int totalOrders;
  final DateTime? startDate;
  final DateTime? endDate;

  factory RevenueSummary.fromJson(Map<String, dynamic> json) {
    return RevenueSummary(
      totalRevenue: (json['totalRevenue'] ?? json['TotalRevenue'] ?? 0).toDouble(),
      totalOrders: (json['totalOrders'] ?? json['TotalOrders'] ?? 0) as int,
      startDate: _readDate(json, 'startDate', 'StartDate'),
      endDate: _readDate(json, 'endDate', 'EndDate'),
    );
  }

  static DateTime? _readDate(
    Map<String, dynamic> json,
    String camel,
    String pascal,
  ) {
    final value = json[camel] ?? json[pascal];
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
