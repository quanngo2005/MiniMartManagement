class HourlyRevenue {
  const HourlyRevenue({
    required this.hour,
    required this.date,
    required this.revenue,
    required this.orderCount,
  });

  final int hour;
  final DateTime date;
  final double revenue;
  final int orderCount;

  factory HourlyRevenue.fromJson(Map<String, dynamic> json) {
    return HourlyRevenue(
      hour: json['hour'] ?? json['Hour'] ?? 0,
      date: DateTime.parse(
        json['date'] ?? json['Date'] ?? DateTime.now().toIso8601String(),
      ),
      revenue: (json['revenue'] ?? json['Revenue'] ?? 0.0).toDouble(),
      orderCount: json['orderCount'] ?? json['OrderCount'] ?? 0,
    );
  }
}
