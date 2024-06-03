import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

class CTagItemTappableWidget extends StatelessWidget {
  final TagModel tag;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const CTagItemTappableWidget({
    super.key,
    required this.tag,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: ActionChip(
        onPressed: onTap,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.label,
              size: 12,
              color: tag.color,
            ),
            const Gap(4),
            Text(
              tag.getName(context),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: const BorderSide(
            color: Colors.transparent,
          ),
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class CTagItemWidget extends StatelessWidget {
  final TagModel tag;
  final Color? backgroundColor;

  const CTagItemWidget({
    super.key,
    required this.tag,
    this.backgroundColor,
  });
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.label,
            size: 12,
            color: tag.color,
          ),
          const Gap(4),
          Text(
            tag.getName(context),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: const BorderSide(
          color: Colors.transparent,
        ),
      ),
    );
  }
}
