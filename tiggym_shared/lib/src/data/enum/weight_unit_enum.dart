import 'package:flutter/material.dart';

import '../../util/extensions/string_extensions.dart';

enum WeightUnitEnum {
  kilogram(toBase: 1000, fromBase: 1 / 1000),
  pounds(toBase: 453.592, fromBase: 1 / 453.592);

  final double fromBase;
  final double toBase;

  const WeightUnitEnum({
    required this.fromBase,
    required this.toBase,
  });

  String getLabel(BuildContext context) => 'label${name.capitalize()}'.getTranslation(context);

  static WeightUnitEnum fromName(String name) => WeightUnitEnum.values.firstWhere((element) => element.name == name);
}
