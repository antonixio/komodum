import 'package:flutter/material.dart';
import '../../util/extensions/string_extensions.dart';

enum DistanceUnitEnum {
  meter(toBase: 1, fromBase: 1), // default
  kilometer(toBase: 1000, fromBase: 1 / 1000),
  mile(toBase: 1609.35, fromBase: 1 / 1609.35);

  String getLabel(BuildContext context) => 'label${name.capitalize()}'.getTranslation(context);
  String getLabelShort(BuildContext context) => 'label${name.capitalize()}Short'.getTranslation(context);

  final double fromBase;
  final double toBase;

  const DistanceUnitEnum({required this.fromBase, required this.toBase});
  static DistanceUnitEnum fromName(String name) => DistanceUnitEnum.values.firstWhere((element) => element.name == name);
}
