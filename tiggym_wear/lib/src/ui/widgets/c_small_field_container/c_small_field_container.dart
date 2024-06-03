import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CSmallFieldContainer extends StatelessWidget {
  final String text;
  final String title;
  final VoidCallback? onTap;

  const CSmallFieldContainer({
    super.key,
    required this.text,
    this.title = '-',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
        ),
        const Gap(2),
        Material(
          clipBehavior: Clip.antiAlias,
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12.0),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
