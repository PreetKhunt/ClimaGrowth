import 'package:intl/intl.dart';

class Formatters {
  static String date(DateTime dt) => DateFormat('dd MMM yyyy').format(dt);
  static String time(DateTime dt) => DateFormat('hh:mm a').format(dt);
  static String dateTime(DateTime dt) => DateFormat('dd MMM, hh:mm a').format(dt);
  static String temperature(double c) => '${c.toStringAsFixed(1)}°C';
  static String humidity(double h) => '${h.toStringAsFixed(0)}%';
  static String windSpeed(double ws) => '${ws.toStringAsFixed(1)} km/h';
  static String rainfall(double mm) => '${mm.toStringAsFixed(1)} mm';
  static String moisture(double m) => '${m.toStringAsFixed(0)}%';
  static String price(double p) => '₹${NumberFormat('#,##0').format(p)}';
  static String acres(double a) => '${a.toStringAsFixed(2)} acres';
  static String litres(double l) => '${l.toStringAsFixed(0)} L';

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
