class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException([
    this.message = 'Session expired. Please login again.',
  ]);
  final String message;
  @override
  String toString() => message;
}
