class EmployeeUser {
  const EmployeeUser({
    required this.employeeId,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.username,
    required this.status,
    required this.roleId,
    required this.roleName,
    required this.permissions,
    this.email,
    this.address,
  });

  final int employeeId;
  final String fullName;
  final bool gender;
  final DateTime dateOfBirth;
  final String username;
  final String? email;
  final String? address;
  final int status;
  final int roleId;
  final String roleName;
  final List<String> permissions;

  factory EmployeeUser.fromJson(Map<String, dynamic> json) {
    return EmployeeUser(
      employeeId: _readInt(json, 'employeeId', 'EmployeeId'),
      fullName: _readString(json, 'fullName', 'FullName'),
      gender: _readBool(json, 'gender', 'Gender'),
      dateOfBirth: DateTime.parse(
        _readString(json, 'dateOfBirth', 'DateOfBirth'),
      ),
      username: _readString(json, 'username', 'Username'),
      email: _readNullableString(json, 'email', 'Email'),
      address: _readNullableString(json, 'address', 'Address'),
      status: _readInt(json, 'status', 'Status'),
      roleId: _readInt(json, 'roleId', 'RoleId'),
      roleName: _readString(json, 'roleName', 'RoleName'),
      permissions: _readStringList(json, 'permissions', 'Permissions'),
    );
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

  static String _readString(
    Map<String, dynamic> json,
    String camelKey,
    String pascalKey,
  ) {
    final value = json[camelKey] ?? json[pascalKey];
    if (value is String) return value;
    throw FormatException('Invalid $camelKey.');
  }

  static bool _readBool(
    Map<String, dynamic> json,
    String camelKey,
    String pascalKey,
  ) {
    final value = json[camelKey] ?? json[pascalKey];
    if (value is bool) return value;
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

  static List<String> _readStringList(
    Map<String, dynamic> json,
    String camelKey,
    String pascalKey,
  ) {
    final value = json[camelKey] ?? json[pascalKey];
    if (value is List) return value.whereType<String>().toList();
    throw FormatException('Invalid $camelKey.');
  }
}
