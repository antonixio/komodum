import 'package:flutter/material.dart';

extension BuildContextExtensions<T> on BuildContext {
  Future<dynamic> push(WidgetBuilder builder) => Navigator.of(this).push(MaterialPageRoute(builder: builder));
  Future<dynamic> pushReplacementNamed(String routeName) => Navigator.of(this).pushReplacementNamed(routeName);
  void pop([dynamic value]) => Navigator.of(this).pop(value);
  void popWhileCan([dynamic value]) => Navigator.of(this).popUntil((value) => value.isFirst);
  void maybePop([dynamic value]) => Navigator.of(this).maybePop(value);
}
