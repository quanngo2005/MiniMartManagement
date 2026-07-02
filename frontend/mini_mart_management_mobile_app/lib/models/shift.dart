class Shift {
  const Shift({
    required this.shiftId,
    required this.shiftCode,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.workDate,
    required this.startCash,
    required this.endCash,
    required this.revenue,
    required this.status,
    this.note,
    this.startedAt,
    this.closedAt,
    required this.employeeId,
    this.cashierId,
  });

  final int shiftId;
  final String shiftCode;
  final String shiftName;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime workDate;
  final double startCash;
  final double endCash;
  final double revenue;
  final int status; // 1 = Pending, 2 = Working, 3 = Closed, 4 = Cancelled
  final String? note;
  final DateTime? startedAt;
  final DateTime? closedAt;
  final int employeeId;
  final int? cashierId;

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      shiftId: _readInt(json, 'shiftId', 'ShiftId'),
      shiftCode: _readString(json, 'shiftCode', 'ShiftCode'),
      shiftName: _readString(json, 'shiftName', 'ShiftName'),
      startTime: DateTime.parse(_readString(json, 'startTime', 'StartTime')),
      endTime: DateTime.parse(_readString(json, 'endTime', 'EndTime')),
      workDate: DateTime.parse(_readString(json, 'workDate', 'WorkDate')),
      startCash: _readDouble(json, 'startCash', 'StartCash'),
      endCash: _readDouble(json, 'endCash', 'EndCash'),
      revenue: _readDouble(json, 'revenue', 'Revenue'),
      status: _readInt(json, 'status', 'Status'),
      note: _readNullableString(json, 'note', 'Note'),
      startedAt: json['startedAt'] != null || json['StartedAt'] != null
          ? DateTime.parse(_readString(json, 'startedAt', 'StartedAt'))
          : null,
      closedAt: json['closedAt'] != null || json['ClosedAt'] != null
          ? DateTime.parse(_readString(json, 'closedAt', 'ClosedAt'))
          : null,
      employeeId: _readInt(json, 'employeeId', 'EmployeeId'),
      cashierId: json['cashierId'] != null || json['CashierId'] != null
          ? _readInt(json, 'cashierId', 'CashierId')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shiftId': shiftId,
      'shiftCode': shiftCode,
      'shiftName': shiftName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'workDate': workDate.toIso8601String(),
      'startCash': startCash,
      'endCash': endCash,
      'revenue': revenue,
      'status': status,
      'note': note,
      'startedAt': startedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'employeeId': employeeId,
      'cashierId': cashierId,
    };
  }

  static int _readInt(
    Map<String, dynamic> json,
    String camelKey,
    String pascalKey,
  ) {
    final value = json[camelKey] ?? json[pascalKey];
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw FormatException('Invalid $camelKey.');
  }

  static double _readDouble(
    Map<String, dynamic> json,
    String camelKey,
    String pascalKey,
  ) {
    final value = json[camelKey] ?? json[pascalKey];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    throw FormatException('Invalid $camelKey.');
  }

  static String _readString(
    Map<String, dynamic> json,
    String camelKey,
    String pascalKey,
  ) {
    final value = json[camelKey] ?? json[pascalKey];
    if (value is String) return value;
    throw FormatException('Invalid $camelKey.');
  }

  static String? _readNullableString(
    Map<String, dynamic> json,
    String camelKey,
    String pascalKey,
  ) {
    final value = json[camelKey] ?? json[pascalKey];
    if (value == null || value is String) return value;
    throw FormatException('Invalid $camelKey.');
  }
}
