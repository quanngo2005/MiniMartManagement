class DailyRevenue {
  const DailyRevenue({
    required this.day,
    required this.date,
    required this.revenue,
    required this.orderCount,
  });

  final int day;
  final DateTime date;
  final double revenue;
  final int orderCount;

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      day: json['day'] ?? json['Day'] ?? 0,
      date: DateTime.parse(
        json['date'] ?? json['Date'] ?? DateTime.now().toIso8601String(),
      ),
      revenue: (json['revenue'] ?? json['Revenue'] ?? 0.0).toDouble(),
      orderCount: json['orderCount'] ?? json['OrderCount'] ?? 0,
    );
  }
}
