extension DoubleExtensions on double {
  double times(num value) => this * value;
  double decimals(int fractionDigits) => double.parse(toStringAsFixed(fractionDigits));
  int getMaxNextValue() {
    final a = toInt().abs().toString();
    final b = '1${List.generate(a.length - 1, (index) => "0").join()}';
    final c = int.parse(b);
    final d = ((this ~/ c.abs()) * c) + c;
    return d;
  }

  double getInterval({
    int values = 4,
  }) {
    final d = getMaxNextValue();
    return (d / (values - 1));
  }

  List<double> getIntervals({
    int values = 5,
  }) {
    final d = getMaxNextValue();

    final interval = (d / (values - 1));
    final intervals = List.generate(values, (index) {
      if (index == (values - 1)) return d.toDouble();

      return index * interval;
    });
    return intervals;
  }
}
