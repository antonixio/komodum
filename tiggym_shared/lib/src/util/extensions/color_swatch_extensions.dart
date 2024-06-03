import 'package:flutter/material.dart';

extension ColorSwatchExtensions<T> on ColorSwatch {
  Color getColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? this[200]! : this[700]!;
}
