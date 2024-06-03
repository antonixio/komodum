import 'package:flutter/material.dart';
import 'package:tiggym_wear/src/util/wear_ui_helper.dart';
import 'package:wear/wear.dart';

class CSafeViewContainerWidget extends StatelessWidget {
  final Widget child;
  const CSafeViewContainerWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        var screenSize = MediaQuery.of(context).size;
        if (shape == WearShape.round) {
          // boxInsetLength requires radius, so divide by 2
          screenSize = Size(
            WearUIHelper.boxInsetLength(screenSize.width / 2),
            WearUIHelper.boxInsetLength(screenSize.height / 2),
          );
        }
        var screenHeight = screenSize.height;
        var screenWidth = screenSize.width;

        return Center(
          child: SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
