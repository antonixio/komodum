import 'package:flutter/material.dart';

import '../../util/extensions/string_extensions.dart';

enum WeightUnitEnum {
  kilogram,
  pounds;

  String getLabel(BuildContext context) => 'label${name.capitalize()}'.getTranslation(context);

  static WeightUnitEnum fromName(String name) => WeightUnitEnum.values.firstWhere((element) => element.name == name);
}
