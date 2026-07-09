class MonthlyFinancialReport {
  const MonthlyFinancialReport({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.incomeGrowthPercent,
    required this.expenseGrowthPercent,
    required this.profitGrowthPercent,
    required this.supplierInvoiceCount,
    required this.supplierDebt,
    required this.dailyPoints,
    required this.supplierSummaries,
  });

  final int month;
  final int year;
  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final double incomeGrowthPercent;
  final double expenseGrowthPercent;
  final double profitGrowthPercent;
  final int supplierInvoiceCount;
  final double supplierDebt;
  final List<MonthlyFinancialPoint> dailyPoints;
  final List<MonthlySupplierSummary> supplierSummaries;

  factory MonthlyFinancialReport.fromJson(Map<String, dynamic> json) {
    final totalIncome = _asDouble(json['totalIncome'] ?? json['TotalIncome']);
    final totalExpenses = _asDouble(json['totalExpenses'] ?? json['TotalExpenses']);

    return MonthlyFinancialReport(
      month: _asInt(json['month'] ?? json['Month']),
      year: _asInt(json['year'] ?? json['Year']),
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netProfit: _asDouble(json['netProfit'] ?? json['NetProfit']) == 0
          ? totalIncome - totalExpenses
          : _asDouble(json['netProfit'] ?? json['NetProfit']),
      incomeGrowthPercent: _asDouble(
        json['incomeGrowthPercent'] ?? json['IncomeGrowthPercent'],
      ),
      expenseGrowthPercent: _asDouble(
        json['expenseGrowthPercent'] ?? json['ExpenseGrowthPercent'],
      ),
      profitGrowthPercent: _asDouble(
        json['profitGrowthPercent'] ?? json['ProfitGrowthPercent'],
      ),
      supplierInvoiceCount:
          _asInt(json['supplierInvoiceCount'] ?? json['SupplierInvoiceCount']),
      supplierDebt: _asDouble(json['supplierDebt'] ?? json['SupplierDebt']),
      dailyPoints: _parseDailyPoints(json),
      supplierSummaries: _parseSupplierSummaries(json),
    );
  }

  static List<MonthlyFinancialPoint> _parseDailyPoints(Map<String, dynamic> json) {
    final raw = json['dailyPoints'] ?? json['DailyPoints'];
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(MonthlyFinancialPoint.fromJson)
          .toList();
    }
    return const [];
  }

  static List<MonthlySupplierSummary> _parseSupplierSummaries(
    Map<String, dynamic> json,
  ) {
    final raw = json['supplierSummaries'] ?? json['SupplierSummaries'];
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(MonthlySupplierSummary.fromJson)
          .toList();
    }
    return const [];
  }
}

class MonthlyFinancialPoint {
  const MonthlyFinancialPoint({
    required this.day,
    required this.date,
    required this.income,
    required this.expense,
    required this.profit,
  });

  final int day;
  final DateTime date;
  final double income;
  final double expense;
  final double profit;

  factory MonthlyFinancialPoint.fromJson(Map<String, dynamic> json) {
    return MonthlyFinancialPoint(
      day: _asInt(json['day'] ?? json['Day']),
      date: DateTime.parse(
        json['date'] ?? json['Date'] ?? DateTime.now().toIso8601String(),
      ),
      income: _asDouble(json['income'] ?? json['Income']),
      expense: _asDouble(json['expense'] ?? json['Expense']),
      profit: _asDouble(json['profit'] ?? json['Profit']),
    );
  }
}

class MonthlySupplierSummary {
  const MonthlySupplierSummary({
    required this.supplierId,
    required this.supplierName,
    required this.invoiceCount,
    required this.totalExpense,
    required this.totalDebt,
  });

  final int supplierId;
  final String supplierName;
  final int invoiceCount;
  final double totalExpense;
  final double totalDebt;

  factory MonthlySupplierSummary.fromJson(Map<String, dynamic> json) {
    return MonthlySupplierSummary(
      supplierId: _asInt(json['supplierId'] ?? json['SupplierId']),
      supplierName: json['supplierName'] ?? json['SupplierName'] ?? '',
      invoiceCount: _asInt(json['invoiceCount'] ?? json['InvoiceCount']),
      totalExpense: _asDouble(json['totalExpense'] ?? json['TotalExpense']),
      totalDebt: _asDouble(json['totalDebt'] ?? json['TotalDebt']),
    );
  }
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
