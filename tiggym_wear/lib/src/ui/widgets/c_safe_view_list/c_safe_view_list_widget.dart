import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tiggym_wear/src/util/wear_ui_helper.dart';
import 'package:wear/wear.dart';

class CSafeViewListWidget extends StatefulWidget {
  final List<Widget> children;
  final double horizontalPadding;
  final double topPadding;
  final double? initialScroll;
  const CSafeViewListWidget({
    super.key,
    required this.children,
    this.horizontalPadding = 8,
    this.topPadding = 8,
    this.initialScroll,
  });

  @override
  State<CSafeViewListWidget> createState() => _CSafeViewListWidgetState();
}

class _CSafeViewListWidgetState extends State<CSafeViewListWidget> {
  ScrollController? scrollController;
  final key = UniqueKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(builder: (context, shape, child) {
      var screenSize = MediaQuery.of(context).size;
      var shapeSize = Size.copy(screenSize);
      if (shape == WearShape.round) {
        // boxInsetLength requires radius, so divide by 2
        shapeSize = Size(WearUIHelper.boxInsetLength(screenSize.width / 2), WearUIHelper.boxInsetLength(screenSize.height / 2));
      }
      scrollController ??= ScrollController(initialScrollOffset: (screenSize.height - shapeSize.height) / 2 + (widget.initialScroll ?? 0));

      return ListView(
        key: key,
        shrinkWrap: true,
        controller: scrollController,
        padding: EdgeInsets.only(
            top: screenSize.height - shapeSize.height + widget.topPadding, bottom: screenSize.height - shapeSize.height, left: widget.horizontalPadding, right: widget.horizontalPadding),
        children: widget.children,
      );
    });
  }

  @override
  void dispose() {
    scrollController?.dispose();
    super.dispose();
  }
}
