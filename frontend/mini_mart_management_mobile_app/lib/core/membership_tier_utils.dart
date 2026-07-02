abstract final class MembershipTierUtils {
  static const int goldThreshold = 10000;
  static const int silverThreshold = 5000;
  static const int bronzeThreshold = 1000;

  static String tierNameForPoints(int points) {
    if (points >= goldThreshold) return 'Gold';
    if (points >= silverThreshold) return 'Silver';
    return 'Bronze';
  }

  static int tierLevelForPoints(int points) {
    if (points >= goldThreshold) return 3;
    if (points >= silverThreshold) return 2;
    return 1;
  }

  static String? previousTierName(int points) {
    final current = tierNameForPoints(points);
    switch (current) {
      case 'Gold':
        return 'Silver';
      case 'Silver':
        return 'Bronze';
      default:
        return null;
    }
  }
}
