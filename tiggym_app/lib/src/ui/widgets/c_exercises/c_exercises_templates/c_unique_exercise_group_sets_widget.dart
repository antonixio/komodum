import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import 'c_unique_exercise_set_group_widget.dart';

class CUniqueExerciseGroupSetsWidget extends StatelessWidget {
  final ExerciseGroupTrainingTemplateModel exerciseGroup;
  final bool editable;
  final void Function(ExerciseGroupTrainingTemplateModel exerciseGroup)? onChanged;

  const CUniqueExerciseGroupSetsWidget({
    super.key,
    required this.exerciseGroup,
    this.editable = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: exerciseGroup.exercises.first.groupSets
          .map<Widget>(
            (e) => CUniqueExerciseGroupSetGroupWidget(
              exerciseSetGroup: e,
              editable: editable,
              onChanged: (setGroup) {
                onChanged?.call(
                  exerciseGroup.changeAndValidate(
                    exercises: exerciseGroup.exercises
                        .replaceWith(
                          exerciseGroup.exercises.first,
                          exerciseGroup.exercises.first.changeAndValidate(
                            groupSets: exerciseGroup.exercises.first.groupSets.replaceWith(e, setGroup).toList(),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          )
          .addBetween(const Gap(8))
          .toList(),
    );
  }
}
