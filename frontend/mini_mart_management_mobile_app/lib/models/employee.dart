class Employee {
  const Employee({
    required this.employeeId,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.phoneNumber,
    this.email,
    this.address,
    required this.username,
    required this.salary,
    required this.hireDate,
    this.avatar,
    required this.status,
    required this.roleId,
    required this.roleName,
  });

  final int employeeId;
  final String fullName;
  final bool gender;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String username;
  final double salary;
  final DateTime hireDate;
  final String? avatar;
  final int status;
  final int roleId;
  final String roleName;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: _readInt(json, 'employeeId', 'EmployeeId'),
      fullName: _readString(json, 'fullName', 'FullName'),
      gender: _readBool(json, 'gender', 'Gender'),
      dateOfBirth: DateTime.parse(
        _readString(json, 'dateOfBirth', 'DateOfBirth'),
      ),
      phoneNumber: _readString(json, 'phoneNumber', 'PhoneNumber'),
      email: _readNullableString(json, 'email', 'Email'),
      address: _readNullableString(json, 'address', 'Address'),
      username: _readString(json, 'username', 'Username'),
      salary: _readDouble(json, 'salary', 'Salary'),
      hireDate: DateTime.parse(_readString(json, 'hireDate', 'HireDate')),
      avatar: _readNullableString(json, 'avatar', 'Avatar'),
      status: _readInt(json, 'status', 'Status'),
      roleId: _readInt(json, 'roleId', 'RoleId'),
      roleName: _readString(json, 'roleName', 'RoleName'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'username': username,
      'salary': salary,
      'hireDate': hireDate.toIso8601String(),
      'avatar': avatar,
      'status': status,
      'roleId': roleId,
      'roleName': roleName,
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
}
