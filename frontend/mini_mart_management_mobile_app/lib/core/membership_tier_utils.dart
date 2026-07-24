abstract final class MembershipTierUtils {
  static const int goldThreshold = 1000;
  static const int silverThreshold = 500;
  static const int bronzeThreshold = 0;

  static String tierNameForPoints(int points) {
    if (points >= goldThreshold) return 'Vàng';
    if (points >= silverThreshold) return 'Bạc';
    return 'Đồng';
  }

  static int tierLevelForPoints(int points) {
    if (points >= goldThreshold) return 3;
    if (points >= silverThreshold) return 2;
    return 1;
  }

  static String? previousTierName(int points) {
    final current = tierNameForPoints(points);
    switch (current) {
      case 'Vàng':
        return 'Bạc';
      case 'Bạc':
        return 'Đồng';
      default:
        return null;
    }
  }
}
