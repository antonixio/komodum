import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;
  DateTime get lastMillisecond => copyWith(hour: 23, minute: 59, second: 59, millisecond: 999, microsecond: 999);
  DateTime get lastDayOfMonth => copyWith(month: month + 1, day: 0);
  DateTime get dateOnly => copyWith(
        year: year,
        month: month,
        day: day,
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
        isUtc: true,
      );

  DateTime get mostRecentSunday => mostRecentWeekday(DateTime.sunday);
  DateTime get lastDayOfWeek => dateOnly.add(const Duration(days: 7)).subtract(const Duration(milliseconds: 1));

  DateTime mostRecentWeekday(int weekday) => dateOnly.copyWith(year: year, month: month, day: day - (this.weekday - weekday) % 7);

  String format(String f) => DateFormat(f).format(copyWith());

  List<DateTime> getDaysUntil({required DateTime end}) {
    DateTime date = dateOnly;
    List<DateTime> dates = [];
    while (date.compareTo(end.dateOnly) <= 0) {
      dates.add(date);
      date = date.add(const Duration(days: 1));
    }

    return dates;
  }

  DateTime addMonths(int months) => DateTime(year, month + months, 1);

  bool isBetween(DateTime start, DateTime end) => dateOnly.compareTo(start.dateOnly) >= 0 && dateOnly.compareTo(end.dateOnly) <= 0;
}
