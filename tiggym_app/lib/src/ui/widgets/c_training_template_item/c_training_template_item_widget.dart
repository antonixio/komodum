import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../c_heatmap/c_heatmap.dart';
import '../c_tag_item/c_tag_item_widget.dart';

class CTrainingTemplateItemWidget extends StatelessWidget {
  final TrainingTemplateResumeModel trainingTemplateResume;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const CTrainingTemplateItemWidget({
    super.key,
    required this.trainingTemplateResume,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                trainingTemplateResume.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Gap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: trainingTemplateResume.tags
                    .map((e) => CTagItemWidget(
                          tag: e,
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        ))
                    .toList(),
              ),
            ),
            const Gap(12),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: HeatMap(
            //     defaultColor: Theme.of(context).colorScheme.surfaceVariant,
            //     // flexible: true,
            //     colorMode: ColorMode.color,
            //     // scrollable: true,
            //     fontSize: 0,
            //     startDate: DateTime.now().copyWith(day: 1, month: 1, year: DateTime.now().year - 1),
            //     size: 10,
            //     borderRadius: 2,
            //     margin: const EdgeInsets.all(1.2),
            //     scrollable: true,
            //     datasets: trainingTemplateResume.lastSessions.groupBy((p0) => p0.dateOnly).map((key, value) => MapEntry(key, value.length)),
            //     showColorTip: false,
            //     showText: false,
            //     onClick: (_) => onTap(),
            //     colorsets: {
            //       1: Theme.of(context).colorScheme.primary,
            //     },
            //   ),
            // ),
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CHeatMap(
                startAt: DateTime.now().copyWith(day: 1, month: 1, year: DateTime.now().year - 1),
                defaultColor: Theme.of(context).colorScheme.surfaceVariant,
                colorsets: {
                  1: Theme.of(context).colorScheme.primary,
                },
              ),
            ),
            const Gap(12),
          ],
        ),
      ),
    );
  }
}
