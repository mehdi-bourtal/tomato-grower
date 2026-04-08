import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _timestampFmt = DateFormat("MMM d, yyyy · HH:mm");
  static final _chartDayFmt = DateFormat("MMM d");
  static final _chartTimeFmt = DateFormat("HH:mm");

  static String formatTimestamp(DateTime? dt) {
    if (dt == null) return '—';
    return _timestampFmt.format(dt.toLocal());
  }

  static String formatChartLabel(DateTime dt, Duration range) {
    if (range.inHours <= 24) {
      return _chartTimeFmt.format(dt.toLocal());
    }
    return _chartDayFmt.format(dt.toLocal());
  }

  static String timeAgo(DateTime? dt) {
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
