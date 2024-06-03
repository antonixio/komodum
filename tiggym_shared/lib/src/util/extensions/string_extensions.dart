import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

extension StringExtensions on String {
  String truncate(int max, {String? end}) {
    if (length > max) {
      final sp = split('').take(max).toList();
      sp.add(end ?? '');
      return sp.join();
    }

    return this;
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String getTranslation(BuildContext context) => getString(context);
}
