class MembershipTier {
  final String id;
  final String name;
  final int requiredPoints;
  final List<String> benefits;
  final String colorCode;

  const MembershipTier({
    required this.id,
    required this.name,
    required this.requiredPoints,
    required this.benefits,
    required this.colorCode,
  });

  MembershipTier copyWith({
    String? id,
    String? name,
    int? requiredPoints,
    List<String>? benefits,
    String? colorCode,
  }) {
    return MembershipTier(
      id: id ?? this.id,
      name: name ?? this.name,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      benefits: benefits ?? this.benefits,
      colorCode: colorCode ?? this.colorCode,
    );
  }
}
