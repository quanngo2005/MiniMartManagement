class PointHistory {
  final String id;
  final DateTime date;
  final int points;
  final String type; // 'Earned' or 'Redeemed'
  final String description;
  final String orderId;

  const PointHistory({
    required this.id,
    required this.date,
    required this.points,
    required this.type,
    required this.description,
    required this.orderId,
  });
}
