class Role {
  const Role({
    required this.roleId,
    required this.roleName,
    this.description,
    required this.status,
  });

  final int roleId;
  final String roleName;
  final String? description;
  final bool status;

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: _readInt(json, 'roleId', 'RoleId'),
      roleName: _readString(json, 'roleName', 'RoleName'),
      description: _readNullableString(json, 'description', 'Description'),
      status: _readBool(json, 'status', 'Status'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'roleName': roleName,
      'description': description,
      'status': status,
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

  static bool _readBool(
    Map<String, dynamic> json,
    String camelKey,
    String pascalKey,
  ) {
    final value = json[camelKey] ?? json[pascalKey];
    if (value is bool) return value;
    throw FormatException('Invalid $camelKey.');
  }
}
