enum StockCountScope {
  global,
  category,
  selected;

  String get label => switch (this) {
    StockCountScope.global => 'Toàn kho',
    StockCountScope.category => 'Theo danh mục',
    StockCountScope.selected => 'Sản phẩm chọn lọc',
  };

  int get apiValue => switch (this) {
    StockCountScope.global => 1,
    StockCountScope.category => 2,
    StockCountScope.selected => 3,
  };
  static StockCountScope fromJson(Object? value) => switch (value) {
    1 || 'Global' => StockCountScope.global,
    2 || 'Category' => StockCountScope.category,
    3 || 'Selected' => StockCountScope.selected,
    _ => throw FormatException('Invalid stock count scope.'),
  };
}

enum StockCountStatus {
  draft,
  counting,
  pendingApproval,
  closed,
  cancelled;

  String get label => switch (this) {
    StockCountStatus.draft => 'Bản nháp',
    StockCountStatus.counting => 'Đang kiểm kê',
    StockCountStatus.pendingApproval => 'Chờ duyệt',
    StockCountStatus.closed => 'Đã hoàn tất',
    StockCountStatus.cancelled => 'Đã hủy',
  };

  static StockCountStatus fromJson(Object? value) => switch (value) {
    1 || 'Draft' => StockCountStatus.draft,
    2 || 'Counting' => StockCountStatus.counting,
    3 || 'PendingApproval' => StockCountStatus.pendingApproval,
    4 || 'Closed' => StockCountStatus.closed,
    5 || 'Cancelled' => StockCountStatus.cancelled,
    _ => throw FormatException('Invalid stock count status.'),
  };
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
    this.startedAt,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
    this.reviewedByEmployeeId,
    this.reviewedByEmployeeName,
    this.categories = const [],
    this.lines = const [],
  });
  final int stockCountId;
  final String stockCountCode;
  final StockCountScope scope;
  final StockCountStatus status;
  final DateTime createdAt;
  final int createdByEmployeeId;
  final String createdByEmployeeName;
  final String rowVersion;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final int? reviewedByEmployeeId;
  final String? reviewedByEmployeeName;
  final List<StockCountCategory> categories;
  final List<StockCountLine> lines;

  factory StockCount.fromJson(Map<String, dynamic> json) => StockCount(
    stockCountId: _int(json, 'stockCountId'),
    stockCountCode: _string(json, 'stockCountCode'),
    scope: StockCountScope.fromJson(_value(json, 'scope')),
    status: StockCountStatus.fromJson(_value(json, 'status')),
    createdAt: DateTime.parse(_string(json, 'createdAt')),
    createdByEmployeeId: _int(json, 'createdByEmployeeId'),
    createdByEmployeeName: _string(json, 'createdByEmployeeName'),
    rowVersion: _string(json, 'rowVersion'),
    startedAt: _date(json, 'startedAt'),
    submittedAt: _date(json, 'submittedAt'),
    reviewedAt: _date(json, 'reviewedAt'),
    rejectionReason: _nullableString(json, 'rejectionReason'),
    reviewedByEmployeeId: _nullableInt(json, 'reviewedByEmployeeId'),
    reviewedByEmployeeName: _nullableString(json, 'reviewedByEmployeeName'),
    categories: _list(
      json,
      'categories',
    ).map(StockCountCategory.fromJson).toList(growable: false),
    lines: _list(
      json,
      'lines',
    ).map(StockCountLine.fromJson).toList(growable: false),
  );
}

class StockCountCategory {
  const StockCountCategory({
    required this.categoryId,
    required this.categoryCode,
    required this.categoryName,
  });
  final int categoryId;
  final String categoryCode;
  final String categoryName;
  factory StockCountCategory.fromJson(Map<String, dynamic> json) =>
      StockCountCategory(
        categoryId: _int(json, 'categoryId'),
        categoryCode: _string(json, 'categoryCode'),
        categoryName: _string(json, 'categoryName'),
      );
}

class StockCountLine {
  const StockCountLine({
    required this.stockCountLineId,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.snapshotQuantity,
    required this.rowVersion,
    this.actualQuantity,
    this.variance,
    this.note,
  });
  final int stockCountLineId;
  final int productId;
  final String productCode;
  final String productName;
  final int snapshotQuantity;
  final int? actualQuantity;
  final int? variance;
  final String? note;
  final String rowVersion;
  factory StockCountLine.fromJson(Map<String, dynamic> json) => StockCountLine(
    stockCountLineId: _int(json, 'stockCountLineId'),
    productId: _int(json, 'productId'),
    productCode: _string(json, 'productCode'),
    productName: _string(json, 'productName'),
    snapshotQuantity: _int(json, 'snapshotQuantity'),
    actualQuantity: _nullableInt(json, 'actualQuantity'),
    variance: _nullableInt(json, 'variance'),
    note: _nullableString(json, 'note'),
    rowVersion: _string(json, 'rowVersion'),
  );
}

Object? _value(Map<String, dynamic> json, String key) =>
    json[key] ?? json['${key[0].toUpperCase()}${key.substring(1)}'];
int _int(Map<String, dynamic> json, String key) {
  final value = _value(json, key);
  if (value is num) return value.toInt();
  throw FormatException('Invalid $key.');
}

int? _nullableInt(Map<String, dynamic> json, String key) {
  final value = _value(json, key);
  return value == null
      ? null
      : value is num
      ? value.toInt()
      : throw FormatException('Invalid $key.');
}

String _string(Map<String, dynamic> json, String key) {
  final value = _value(json, key);
  if (value is String) return value;
  throw FormatException('Invalid $key.');
}

String? _nullableString(Map<String, dynamic> json, String key) {
  final value = _value(json, key);
  return value == null
      ? null
      : value is String
      ? value
      : throw FormatException('Invalid $key.');
}

DateTime? _date(Map<String, dynamic> json, String key) {
  final value = _value(json, key);
  return value == null
      ? null
      : value is String
      ? DateTime.parse(value)
      : throw FormatException('Invalid $key.');
}

List<Map<String, dynamic>> _list(Map<String, dynamic> json, String key) {
  final value = _value(json, key);
  return value is List
      ? value.whereType<Map<String, dynamic>>().toList(growable: false)
      : const [];
}
