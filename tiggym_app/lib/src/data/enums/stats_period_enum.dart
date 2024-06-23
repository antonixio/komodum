import 'package:flutter/material.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

enum StatsPeriodEnum {
  week, // default
  month,
  year,
  all;

  String getLabel(BuildContext context) => 'label${name.capitalize()}'.getTranslation(context);

  static StatsPeriodEnum fromName(String name) => StatsPeriodEnum.values.firstWhere((element) => element.name == name);
}
