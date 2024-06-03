import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/ui/widgets/c_safe_view_list/c_safe_view_list_widget.dart';
import 'package:tiggym_wear/src/util/extensions/build_context_extensions.dart';

import '../../../data/repositories/training_session_repository.dart';
import '../../widgets/c_safe_view_container/c_safe_view_container_widget.dart';
import '../exercises/exercises_screen.dart';

class OngoingExerciseGroupExercisesScreen extends StatelessWidget {
  final String? syncId;
  final void Function(ExerciseGroupTrainingSessionModel exerciseGroup)? onChanged;

  const OngoingExerciseGroupExercisesScreen({
    super.key,
    required this.syncId,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: GetIt.I.get<TrainingSessionRepository>().currentSessions,
        initialData: GetIt.I.get<TrainingSessionRepository>().currentSessions.value,
        builder: (context, snapshot) {
          final session = snapshot.data?.watchSession;
          final data = snapshot.data?.watchSession?.exercises.firstWhereOrNull((e) => e.syncId == syncId);

          final sessionState = snapshot.data?.sessionState;

          if (data == null || session == null || (sessionState != null && sessionState.state != TrainingSessionStateEnum.ongoing)) {
            return CSafeViewContainerWidget(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(switch (sessionState?.state) {
                    TrainingSessionStateEnum.discarded => AppLocale.labelDiscarded.getTranslation(context),
                    TrainingSessionStateEnum.finished => AppLocale.labelFinished.getTranslation(context),
                    _ => AppLocale.messageCouldntOpenWorkout.getTranslation(context),
                  }),
                  IconButton(
                    onPressed: () {
                      if (data == null && session != null) {
                        context.pop();
                        context.pop();
                      } else {
                        context.popWhileCan();
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                    ),
                  )
                ],
              ),
            );
          }

          return CSafeViewListWidget(
            children: [
              Text(
                AppLocale.labelExercises.getTranslation(context),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(16),
              if (data.exercises.isEmpty) Text(AppLocale.messageNothingHereYet.getTranslation(context)),
              ...data.exercises
                  .map<Widget>((e) => Row(
                        children: [
                          Text(e.exercise.getName(context)),
                          const Gap(16),
                          ElevatedButton(
                            onPressed: () {
                              onChanged?.call(
                                data.removeExercise(e),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: const Size.square(24),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: Theme.of(context).colorScheme.onError,
                              surfaceTintColor: Theme.of(context).colorScheme.onError,
                              backgroundColor: Theme.of(context).colorScheme.error,
                            ),
                            child: const Icon(
                              Icons.delete,
                              size: 14,
                            ),
                          ),
                        ],
                      ))
                  .addBetween(const Gap(12)),
              const Gap(16),
              ElevatedButton.icon(
                onPressed: () async {
                  final exercise = await context.push((context) => const ExercisesScreen());
                  if (exercise != null && exercise is ExerciseModel) {
                    onChanged?.call(data.addExercise(exercise));
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(
                  AppLocale.labelAddExercise.getTranslation(context),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
