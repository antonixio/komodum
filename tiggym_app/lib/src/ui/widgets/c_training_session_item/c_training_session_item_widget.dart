import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../c_tag_item/c_tag_item_widget.dart';

class CTrainingSessionItemWidget extends StatefulWidget {
  final TrainingSessionResumeModel trainingSessionResume;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CTrainingSessionItemWidget({
    super.key,
    required this.trainingSessionResume,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<CTrainingSessionItemWidget> createState() => _CTrainingSessionItemWidgetState();
}

class _CTrainingSessionItemWidgetState extends State<CTrainingSessionItemWidget> {
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.trainingSessionResume.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 16,
                  ),
                  const Gap(8),
                  Text(
                    widget.trainingSessionResume.date.format(AppLocale.formatDateTime.getTranslation(context)),
                    style: Theme.of(context).textTheme.labelMedium,
                  )
                ],
              ),
            ),
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Gap(16),
                      const Icon(
                        Icons.timer_sharp,
                        size: 16,
                      ),
                      const Gap(8),
                      Text(
                        widget.trainingSessionResume.duration.hoursMinutesSeconds,
                        style: Theme.of(context).textTheme.labelMedium,
                      )
                    ],
                  ),
                ),
                const Gap(8),
                if (widget.trainingSessionResume.tags.isNotEmpty)
                  InkWell(
                    onTap: () {
                      setState(() {
                        show = !show;
                      });
                    },
                    borderRadius: BorderRadius.circular(80),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        !show ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                      ),
                    ),
                  )
              ],
            ),
            if (!widget.trainingSessionResume.tags.isNotEmpty) const Gap(8),
            AnimatedSize(
              duration: Durations.medium1,
              child: show
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.trainingSessionResume.tags
                            .map((e) => CTagItemWidget(
                                  tag: e,
                                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                                ))
                            .toList(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
