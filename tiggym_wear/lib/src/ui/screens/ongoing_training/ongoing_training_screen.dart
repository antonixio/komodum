import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/data/repositories/training_session_repository.dart';
import 'package:tiggym_wear/src/ui/screens/ongoing_training/ongoing_training_settings_screen.dart';
import 'package:tiggym_wear/src/ui/widgets/c_safe_view_container/c_safe_view_container_widget.dart';
import 'package:tiggym_wear/src/ui/widgets/c_safe_view_list/c_safe_view_list_widget.dart';
import 'package:tiggym_wear/src/util/extensions/build_context_extensions.dart';

import '../../widgets/c_exercises/c_compound_exercise_group/c_compound_exercise_group_widget.dart';
import '../../widgets/c_exercises/c_set_groups/c_set_groups_widget.dart';
import '../../widgets/c_exercises/c_unique_exercise_group/c_unique_exercise_group_widget.dart';
import '../exercises/exercises_screen.dart';

class OngoingTrainingScreen extends StatelessWidget {
  const OngoingTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: GetIt.I.get<TrainingSessionRepository>().currentSessions,
        initialData: GetIt.I.get<TrainingSessionRepository>().currentSessions.value,
        builder: (context, snapshot) {
          final data = snapshot.data?.watchSession;
          final sessionState = snapshot.data?.sessionState;

          if (data == null || (sessionState != null && sessionState.state != TrainingSessionStateEnum.ongoing)) {
            return Scaffold(
              body: CSafeViewContainerWidget(
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
                        context.popWhileCan();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                    )
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            body: CSafeViewListWidget(
              horizontalPadding: 16,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: Key(data.name),
                        decoration: const InputDecoration.collapsed(hintText: "..."),
                        initialValue: data.name,
                      ),
                    ),
                    const Gap(8),
                    IconButton(
                        onPressed: () {
                          context.push((context) => OngoingTrainingSettingsScreen(
                                onCancel: () {
                                  context.pop();
                                  GetIt.I.get<TrainingSessionRepository>().finishSession();
                                  // onChanged?.call(exerciseGroup.addSimpleSet());
                                },
                                onAddCompoundExercise: () async {
                                  final exercise = await context.push((context) => const ExercisesScreen());
                                  if (exercise != null && exercise is ExerciseModel) {
                                    GetIt.I.get<TrainingSessionRepository>().changeSession(data.addCompoundExercise(exercise));
                                  }
                                },
                                onAddExercise: () async {
                                  final exercise = await context.push((context) => const ExercisesScreen());
                                  if (exercise != null && exercise is ExerciseModel) {
                                    GetIt.I.get<TrainingSessionRepository>().changeSession(data.addSimpleExercise(exercise));
                                  }
                                },
                                onFinish: () {
                                  context.pop();
                                  GetIt.I.get<TrainingSessionRepository>().finishSession();
                                },
                              ));
                        },
                        icon: const Icon(Icons.settings)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month, size: 12),
                              const Gap(6),
                              Expanded(
                                child: Text(
                                  data.date.format(AppLocale.formatDateTime.getTranslation(context)),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          OngoingTrainingDurationWidget(start: data.date),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                ...data.exercises
                    .map<Widget>(
                      (e) => e.groupType == ExerciseGroupTypeEnum.unique
                          ? CUniqueExerciseGroupWidget(
                              exerciseGroup: e,
                            )
                          : CCompoundExerciseGroupWidget(
                              exerciseGroup: e,
                            ),
                    )
                    .addBetween(const Gap(16)),
              ],
            ),
          );
        });
  }
}

class OngoingTrainingDurationWidget extends StatelessWidget {
  final DateTime start;
  const OngoingTrainingDurationWidget({
    super.key,
    required this.start,
  });

  @override
  build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(Durations.medium2),
      builder: (context, snapshot) {
        final dur = Duration(seconds: DateTime.now().secondsSinceEpoch - start.secondsSinceEpoch);
        return Row(
          children: [
            const Icon(Icons.timer, size: 12),
            const Gap(6),
            Text(
              dur.hoursMinutesSeconds,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}
