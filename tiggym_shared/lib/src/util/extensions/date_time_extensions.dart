import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;
  DateTime get lastDayOfMonth => copyWith(month: month + 1, day: 0);
  DateTime get dateOnly => DateTime(year, month, day);

  String format(String f) => DateFormat(f).format(copyWith());
}
