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
}
