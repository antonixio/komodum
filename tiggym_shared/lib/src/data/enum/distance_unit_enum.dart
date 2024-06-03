import 'package:flutter/material.dart';
import '../../util/extensions/string_extensions.dart';

import '../../util/extensions/string_extensions.dart';

enum DistanceUnitEnum {
  meter(value: 1), // default
  kilometer(value: 1000),
  mile(value: 1609.34);

  String getLabel(BuildContext context) => 'label${name.capitalize()}'.getTranslation(context);
  String getLabelShort(BuildContext context) => 'label${name.capitalize()}Short'.getTranslation(context);

  final double value;

  const DistanceUnitEnum({required this.value});
  static DistanceUnitEnum fromName(String name) => DistanceUnitEnum.values.firstWhere((element) => element.name == name);
}
