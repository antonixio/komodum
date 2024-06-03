import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

class CTopRightActionsWidget extends StatelessWidget {
  final Widget child;
  final List<Widget> actions;
  final double top;
  final double right;
  const CTopRightActionsWidget({
    super.key,
    required this.child,
    required this.actions,
    this.top = 0,
    this.right = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: top,
          right: right,
          child: Row(
            children: actions.addBetween(const Gap(4)).toList(),
          ),
        )
      ],
    );
  }
}
