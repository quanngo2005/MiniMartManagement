class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException([
    this.message = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
  ]);
  final String message;
  @override
  String toString() => message;
}
