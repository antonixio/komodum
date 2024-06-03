extension DurationFormatting on Duration {
  String get hoursMinutesSeconds => '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

extension DurationValue on Duration {
  Duration zeroIfNegative() {
    return isNegative ? const Duration() : this;
  }

  int get hours => inHours % 60;
  int get minutes => inMinutes % 60;
  int get seconds => inSeconds % 60;
}
