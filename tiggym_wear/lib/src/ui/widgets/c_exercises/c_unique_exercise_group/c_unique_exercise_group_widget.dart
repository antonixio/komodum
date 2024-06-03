import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/ui/screens/ongoing_training/ongoing_exercise_group_details_screen.dart';
import 'package:tiggym_wear/src/util/extensions/build_context_extensions.dart';

import '../c_set_groups/c_set_groups_widget.dart';

class CUniqueExerciseGroupWidget extends StatelessWidget {
  final ExerciseGroupTrainingSessionModel exerciseGroup;
  ExerciseTrainingSessionModel get exercise => exerciseGroup.exercises.first;
  const CUniqueExerciseGroupWidget({
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
                        exercise.exercise.getName(context),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
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
                  groups: exercise.groupSets,
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
