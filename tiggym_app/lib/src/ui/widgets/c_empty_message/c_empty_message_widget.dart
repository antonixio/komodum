import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CEmptyMessageWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  const CEmptyMessageWidget({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "👻",
          style: TextStyle(fontSize: 30),
        ),
        const Gap(8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Gap(8),
        Text(subtitle)
      ],
    );
  }
}
