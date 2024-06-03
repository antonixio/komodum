import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/ui/widgets/c_exercises/c_set_groups/c_set_groups_widget.dart';
import 'package:tiggym_wear/src/util/extensions/build_context_extensions.dart';

import '../../../screens/ongoing_training/ongoing_exercise_group_details_screen.dart';

class CCompoundExerciseGroupWidget extends StatelessWidget {
  final ExerciseGroupTrainingSessionModel exerciseGroup;
  const CCompoundExerciseGroupWidget({
    super.key,
    required this.exerciseGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final syncId = exerciseGroup.syncId;
          if (syncId != null) {
            context.push((_) => OngoingExerciseGroupDetailsScreen(syncId: syncId));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0.0,
                      ),
                      child: Text(
                        AppLocale.labelCompound.getTranslation(context),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Text(
                  exerciseGroup.exercises.isNotEmpty ? exerciseGroup.exercises.map((e) => e.exercise.getName(context)).join("; ") : "No exercises...",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Text(AppLocale.labelSets.getTranslation(context)),
              ),
              const Gap(4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: CSetGroupsWidget(
                  groups: List.generate(
                      exerciseGroup.exercises.firstOrNull?.groupSets.length ?? 0,
                      (index) => ExerciseSetGroupTrainingSessionModel(
                          groupType: ExerciseSetGroupTypeEnum.multiple,
                          order: index + 1,
                          sets: exerciseGroup.exercises
                              .map((e) => e.groupSets.elementAt(index))
                              .fold(<ExerciseSetTrainingSessionModel>[], (previousValue, element) => previousValue..addAll(element.sets)))),
                ),
              ),
              const Gap(4),
            ],
          ),
        ),
      ),
    );
  }
}
