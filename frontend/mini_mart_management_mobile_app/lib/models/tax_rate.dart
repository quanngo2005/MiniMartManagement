class TaxRate {
  const TaxRate({
    required this.taxRateId,
    required this.rate,
    required this.description,
    required this.status,
  });

  final int taxRateId;
  final double rate;
  final String description;
  final bool status;

  factory TaxRate.fromJson(Map<String, dynamic> json) {
    return TaxRate(
      taxRateId: _asInt(json['taxRateId'] ?? json['TaxRateId']),
      rate: _asDouble(json['rate'] ?? json['Rate']),
      description: (json['description'] ?? json['Description'] ?? '') as String,
      status: (json['status'] ?? json['Status'] ?? false) == true,
    );
  }
}

int _asInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;

double _asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
