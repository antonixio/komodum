import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as modal_bottom_sheet;

extension BuildContextExtensions<T> on BuildContext {
  Future<dynamic> push(WidgetBuilder builder) => Navigator.of(this).push(MaterialPageRoute(builder: builder));
  void pop([dynamic value]) => Navigator.of(this).pop(value);
  void popWhileCan([dynamic value]) => Navigator.of(this).popUntil((value) => value.isFirst);
  void maybePop([dynamic value]) => Navigator.of(this).maybePop(value);
  Future<dynamic> showMaterialModalBottomSheet(WidgetBuilder builder) => modal_bottom_sheet.showMaterialModalBottomSheet(
        context: this,
        builder: builder,
        clipBehavior: Clip.antiAlias,
        barrierColor: Colors.black.withOpacity(0.7),
        enableDrag: false,
        elevation: 2,
      );
}
