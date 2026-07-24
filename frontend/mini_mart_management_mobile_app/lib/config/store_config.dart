class StoreConfig {
  StoreConfig._();

  static const String name = 'SIÊU THỊ MINI MART';
  static const String address = 'Số 123 Đường Lê Lợi, Phường Bến Nghé, Quận 1';
  static const String phone = '028 3825 6789';
  static const String taxCode = '0123456789';
}

String paymentMethodLabel(int? method) {
  switch (method) {
    case 1:
      return 'Tiền mặt';
    case 5:
      return 'Chuyển khoản / VNPay';
    default:
      return 'Tiền mặt';
  }
}
