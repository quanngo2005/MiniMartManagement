class TaxRate {
  const TaxRate({
    required this.taxRateId,
    required this.rate,
    required this.description,
  });

  final int taxRateId;
  final double rate;
  final String description;

  factory TaxRate.fromJson(Map<String, dynamic> json) {
    return TaxRate(
      taxRateId: (json['taxRateId'] ?? json['TaxRateId'] ?? 0) as int,
      rate: ((json['rate'] ?? json['Rate'] ?? 0) as num).toDouble(),
      description: (json['description'] ?? json['Description'] ?? '') as String,
    );
  }

  String get label => '$description (${(rate * 100).toStringAsFixed(0)}%)';
}
