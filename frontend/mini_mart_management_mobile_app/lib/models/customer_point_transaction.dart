class CustomerPointTransaction {
  final int pointTransactionId;
  final int transactionType; // 1=Earn, 2=Redeem, 3=Adjust, 4=Expire
  final int delta;
  final int balanceAfter;
  final String? note;
  final int? orderId;
  final DateTime? createdAt;

  const CustomerPointTransaction({
    required this.pointTransactionId,
    required this.transactionType,
    required this.delta,
    required this.balanceAfter,
    this.note,
    this.orderId,
    this.createdAt,
  });

  factory CustomerPointTransaction.fromJson(Map<String, dynamic> json) {
    final dateRaw = json['transactionDate'] ?? json['TransactionDate']
        ?? json['createdAt'] ?? json['CreatedAt'];
    return CustomerPointTransaction(
      pointTransactionId:
          (json['pointTransactionId'] ?? json['PointTransactionId'] ?? 0) as int,
      transactionType:
          (json['transactionType'] ?? json['TransactionType'] ?? 1) as int,
      delta: (json['delta'] ?? json['Delta'] ?? 0) as int,
      balanceAfter: (json['balanceAfter'] ?? json['BalanceAfter'] ?? 0) as int,
      note: json['note'] as String? ?? json['Note'] as String?,
      orderId: json['orderId'] as int? ?? json['OrderId'] as int?,
      createdAt: dateRaw != null ? DateTime.tryParse(dateRaw as String) : null,
    );
  }

  bool get isPositive => delta > 0;

  String get typeLabel {
    switch (transactionType) {
      case 2:
        return 'Đổi quà tặng';
      case 3:
        return 'Điều chỉnh';
      case 4:
        return 'Hết hạn';
      default:
        return 'Mua hàng tại quầy';
    }
  }

  String get refCode {
    if (orderId != null) return 'TXN-${orderId.toString().padLeft(6, '0')}';
    return 'ADJ-${pointTransactionId.toString().padLeft(6, '0')}';
  }
}
