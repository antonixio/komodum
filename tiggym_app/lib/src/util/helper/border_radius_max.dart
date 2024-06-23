import 'package:flutter/material.dart';

class BorderRadiusCircularMax extends BorderRadius {
  BorderRadiusCircularMax()
      : super.all(Radius.circular(
          double.maxFinite.floor().abs().toDouble(),
        ));
}
