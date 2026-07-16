enum StockCountScope {
  global,
  category;

  String get label => switch (this) {
    StockCountScope.global => 'Toàn kho',
    StockCountScope.category => 'Theo danh mục',
  };

  static StockCountScope fromJson(Object? value) {
    if (value == 1 || value == 'Global') return StockCountScope.global;
    if (value == 2 || value == 'Category') return StockCountScope.category;
    throw FormatException('Invalid stock count scope.');
  }
}

enum StockCountStatus {
  draft,
  counting,
  pendingApproval,
  closed;

  String get label => switch (this) {
    StockCountStatus.draft => 'Bản nháp',
    StockCountStatus.counting => 'Đang kiểm kê',
    StockCountStatus.pendingApproval => 'Chờ duyệt',
    StockCountStatus.closed => 'Đã hoàn tất',
  };

  static StockCountStatus fromJson(Object? value) {
    return switch (value) {
      1 || 'Draft' => StockCountStatus.draft,
      2 || 'Counting' => StockCountStatus.counting,
      3 || 'PendingApproval' => StockCountStatus.pendingApproval,
      4 || 'Closed' => StockCountStatus.closed,
      _ => throw FormatException('Invalid stock count status.'),
    };
  }
}

class StockCount {
  const StockCount({
    required this.stockCountId,
    required this.stockCountCode,
    required this.scope,
    required this.status,
    required this.createdAt,
    required this.createdByEmployeeId,
    required this.createdByEmployeeName,
    required this.rowVersion,
  });

  final int stockCountId;
  final String stockCountCode;
  final StockCountScope scope;
  final StockCountStatus status;
  final DateTime createdAt;
  final int createdByEmployeeId;
  final String createdByEmployeeName;
  final String rowVersion;

  factory StockCount.fromJson(Map<String, dynamic> json) {
    return StockCount(
      stockCountId: _readInt(json, 'stockCountId', 'StockCountId'),
      stockCountCode: _readString(json, 'stockCountCode', 'StockCountCode'),
      scope: StockCountScope.fromJson(json['scope'] ?? json['Scope']),
      status: StockCountStatus.fromJson(json['status'] ?? json['Status']),
      createdAt: DateTime.parse(_readString(json, 'createdAt', 'CreatedAt')),
      createdByEmployeeId: _readInt(
        json,
        'createdByEmployeeId',
        'CreatedByEmployeeId',
      ),
      createdByEmployeeName: _readString(
        json,
        'createdByEmployeeName',
        'CreatedByEmployeeName',
      ),
      rowVersion: _readString(json, 'rowVersion', 'RowVersion'),
    );
  }
}

int _readInt(Map<String, dynamic> json, String camelKey, String pascalKey) {
  final value = json[camelKey] ?? json[pascalKey];
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('Invalid $camelKey.');
}

String _readString(
  Map<String, dynamic> json,
  String camelKey,
  String pascalKey,
) {
  final value = json[camelKey] ?? json[pascalKey];
  if (value is String) return value;
  throw FormatException('Invalid $camelKey.');
}
