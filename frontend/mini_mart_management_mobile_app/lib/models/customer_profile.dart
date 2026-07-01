class CustomerProfile {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String tier;
  final int points;
  final DateTime registrationDate;
  final DateTime lastVisit;
  final int totalOrders;
  final double totalSpent;

  const CustomerProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.tier,
    required this.points,
    required this.registrationDate,
    required this.lastVisit,
    required this.totalOrders,
    required this.totalSpent,
  });
}
