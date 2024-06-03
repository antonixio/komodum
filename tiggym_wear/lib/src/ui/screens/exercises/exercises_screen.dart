import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/data/repositories/exercise_repository.dart';
import 'package:tiggym_wear/src/util/extensions/build_context_extensions.dart';

import '../../widgets/c_safe_view_list/c_safe_view_list_widget.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: GetIt.I.get<ExerciseRepository>().exercises,
            initialData: GetIt.I.get<ExerciseRepository>().exercises.value,
            builder: (context, snapshot) {
              final exercises = (snapshot.data ?? <ExerciseModel>[])
                ..sort(
                  (a, b) => a.getName(context).toUpperCase().compareTo(b.getName(context).toUpperCase()),
                );
              return CSafeViewListWidget(
                children: exercises
                    .map<Widget>((e) => CExerciseItemWidget(
                          exercise: e,
                        ))
                    .addBetween(const Gap(8))
                    .toList(),
              );
            }));
  }
}

class CExerciseItemWidget extends StatelessWidget {
  final ExerciseModel exercise;
  const CExerciseItemWidget({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final tag = exercise.tag;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.pop(exercise);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exercise.getName(context),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Gap(4),
              if (tag != null) ...[
                Row(
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
                const Gap(4),
              ],
              Text(
                exercise.type.getLabel(context),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
