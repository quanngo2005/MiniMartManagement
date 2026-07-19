class CashierPerformance {
  const CashierPerformance({
    required this.employeeId,
    required this.employeeName,
    required this.totalTransactions,
    required this.totalRevenue,
  });

  final int employeeId;
  final String employeeName;
  final int totalTransactions;
  final double totalRevenue;

  factory CashierPerformance.fromJson(Map<String, dynamic> json) {
    return CashierPerformance(
      employeeId: (json['employeeId'] ?? json['EmployeeId'] ?? 0) as int,
      employeeName:
          (json['employeeName'] ?? json['EmployeeName'] ?? '') as String,
      totalTransactions:
          (json['totalTransactions'] ?? json['TotalTransactions'] ?? 0) as int,
      totalRevenue: (json['totalRevenue'] ?? json['TotalRevenue'] ?? 0)
          .toDouble(),
    );
  }
}
