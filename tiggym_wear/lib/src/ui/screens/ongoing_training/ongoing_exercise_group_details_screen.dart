import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/ui/widgets/c_single_set/c_single_set_widget.dart';
import 'package:tiggym_wear/src/util/extensions/build_context_extensions.dart';

import '../../../data/repositories/training_session_repository.dart';
import '../../widgets/c_safe_view_container/c_safe_view_container_widget.dart';
import '../../widgets/c_safe_view_list/c_safe_view_list_widget.dart';
import '../../widgets/c_toast_container/c_toast_controller.dart';
import 'ongoing_exercise_group_exercises_screen.dart';
import 'ongoing_exercise_group_settings_screen.dart';

class OngoingExerciseGroupDetailsScreen extends StatelessWidget {
  final String syncId;

  const OngoingExerciseGroupDetailsScreen({
    super.key,
    required this.syncId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: GetIt.I.get<TrainingSessionRepository>().currentSessions,
        initialData: GetIt.I.get<TrainingSessionRepository>().currentSessions.value,
        builder: (context, snapshot) {
          final session = snapshot.data?.watchSession;
          final data = snapshot.data?.watchSession?.exercises.firstWhereOrNull((e) => e.syncId == syncId);

          final sessionState = snapshot.data?.sessionState;

          if (data == null || session == null || (sessionState != null && sessionState.state != TrainingSessionStateEnum.ongoing)) {
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
                        if (data == null && session != null) {
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
              ),
            );
          }

          if (data.groupType == ExerciseGroupTypeEnum.unique) {
            return OngoingUniqueExerciseGroupWidget(
              exerciseGroup: data,
              onChanged: (e) {
                GetIt.I.get<TrainingSessionRepository>().changeSession(
                      session.changeAndValidate(
                        exercises: session.exercises.replaceFirstWhere((element) => element.syncId == data.syncId, e).toList(),
                      ),
                    );
              },
              onRemove: () {
                context.pop();
                GetIt.I.get<TrainingSessionRepository>().changeSession(
                      session.changeAndValidate(
                        exercises: [...session.exercises]..removeWhere((element) => element.syncId == data.syncId),
                      ),
                    );
              },
            );
          }

          return OngoingMultipleExerciseGroupWidget(
            exerciseGroup: data,
            onChanged: (e) {
              GetIt.I.get<TrainingSessionRepository>().changeSession(
                    session.changeAndValidate(
                      exercises: session.exercises.replaceFirstWhere((element) => element.syncId == data.syncId, e).toList(),
                    ),
                  );
            },
            onRemove: () {
              context.pop();
              GetIt.I.get<TrainingSessionRepository>().changeSession(
                    session.changeAndValidate(
                      exercises: [...session.exercises]..removeWhere((element) => element.syncId == data.syncId),
                    ),
                  );
            },
          );
        });
  }
}

class OngoingMultipleExerciseGroupWidget extends StatelessWidget {
  final ExerciseGroupTrainingSessionModel exerciseGroup;
  final void Function(ExerciseGroupTrainingSessionModel exerciseGroup)? onChanged;
  final VoidCallback onRemove;

  const OngoingMultipleExerciseGroupWidget({
    super.key,
    required this.exerciseGroup,
    this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CSafeViewListWidget(
        horizontalPadding: 16,
        topPadding: -8,
        children: [
          IconButton(
              onPressed: () {
                context.push((context) => OngoingExerciseGroupeSettingsScreen(
                      onAddSimpleSet: () {
                        onChanged?.call(exerciseGroup.addSimpleSet());
                      },
                      onAddMultipleSet: () {
                        onChanged?.call(exerciseGroup.addMultipleSet());
                      },
                      onRemove: () {
                        onRemove.call();
                      },
                    ));
              },
              icon: const Icon(Icons.settings)),
          Text(
            AppLocale.labelCompound.getTranslation(context),
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Material(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                context.push((context) => OngoingExerciseGroupExercisesScreen(
                      syncId: exerciseGroup.syncId,
                      onChanged: onChanged,
                    ));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (exerciseGroup.exercises.isEmpty) Text(AppLocale.messageNothingHereYet.getTranslation(context)),
                    ...exerciseGroup.exercises.map((e) => Text("- ${e.exercise.getName(context)}")),
                  ],
                ),
              ),
            ),
          ),
          const Gap(16),
          ...List<Widget>.generate(exerciseGroup.exercises.firstOrNull?.groupSets.length ?? 0, (index) {
            final groups = exerciseGroup.exercises.map((ex) => ex.groupSets.elementAtOrNull(index)).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Gap(4),
                    Text(
                      AppLocale.labelSetN.getTranslation(context).replaceAll('%setnumber%', (index + 1).toString()),
                    ),
                    if (groups.every((element) => element?.sets.every((element) => element.done) ?? false)) ...[
                      const Gap(4),
                      Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                    ],
                    const Gap(16),
                    ElevatedButton(
                      onPressed: () {
                        onChanged?.call(
                          exerciseGroup.copyWith(
                            exercises: exerciseGroup.exercises
                                .map(
                                  (e) => e.copyWith(
                                    groupSets: [...e.groupSets]..removeAt(index),
                                  ),
                                )
                                .toList(),
                          ),
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
                ),
                const Gap(4),
                ...exerciseGroup.exercises.map(
                  (e) => Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Theme.of(context).colorScheme.surfaceVariant, width: 2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${(index + 1)}. ${e.exercise.getName(context)}"),
                          const Gap(4),
                          ...e.groupSets
                                  .elementAtOrNull(index)
                                  ?.sets
                                  .map<Widget>(
                                    (eSet) => CSingleSetWidget(
                                      exerciseSet: eSet,
                                      order: eSet.order,
                                      editable: true,
                                      onRemove: () {
                                        final groupSets = e.groupSets.elementAtOrNull(index);
                                        if ((groupSets?.sets.length ?? 0) <= 1) {
                                          GetIt.I
                                              .get<CToastController>()
                                              .addText(text: AppLocale.messageYouNeedAtLeastOneSetForEachExercise.getTranslation(context), duration: const Duration(seconds: 3));
                                          return;
                                        }
                                        if (groupSets != null) {
                                          onChanged?.call(
                                            exerciseGroup.changeAndValidate(
                                              exercises: exerciseGroup.exercises
                                                  .replaceWith(
                                                      e,
                                                      e.changeAndValidate(
                                                        groupSets: e.groupSets
                                                            .replaceWith(
                                                              groupSets,
                                                              groupSets.removeSet(
                                                                eSet,
                                                              ),
                                                            )
                                                            .toList(),
                                                      ))
                                                  .toList(),
                                            ),
                                          );
                                        }
                                      },
                                      onChanged: (p0) {
                                        final groupSets = e.groupSets.elementAtOrNull(index);
                                        if (groupSets != null) {
                                          onChanged?.call(
                                            exerciseGroup.changeAndValidate(
                                              exercises: exerciseGroup.exercises
                                                  .replaceWith(
                                                      e,
                                                      e.changeAndValidate(
                                                        groupSets: e.groupSets
                                                            .replaceWith(
                                                              groupSets,
                                                              groupSets.updateSet(
                                                                eSet,
                                                                p0,
                                                              ),
                                                            )
                                                            .toList(),
                                                      ))
                                                  .toList(),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  )
                                  .addBetween(const Gap(4)) ??
                              [],
                          if (e.groupSets.elementAtOrNull(index)?.groupType == ExerciseSetGroupTypeEnum.multiple)
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  final groupSets = e.groupSets.elementAtOrNull(index);

                                  if (groupSets != null) {
                                    onChanged?.call(
                                      exerciseGroup.changeAndValidate(
                                        exercises: exerciseGroup.exercises
                                            .replaceWith(
                                                e,
                                                e.changeAndValidate(
                                                  groupSets: e.groupSets
                                                      .replaceWith(
                                                        groupSets,
                                                        groupSets.addInnerSet(),
                                                      )
                                                      .toList(),
                                                ))
                                            .toList(),
                                      ),
                                    );
                                  }
                                },
                                child: Text(AppLocale.labelAddInnerSet.getTranslation(context)),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          }).addBetween(const Gap(16)),
          const Gap(16),
          ElevatedButton.icon(
              onPressed: () {
                onChanged?.call(exerciseGroup.addSimpleSet());
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocale.labelAddSimpleSet.getTranslation(context))),
          const Gap(4),
          ElevatedButton.icon(
              onPressed: () {
                onChanged?.call(exerciseGroup.addMultipleSet());
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocale.labelAddMultipleSet.getTranslation(context))),
        ],
      ),
    );
  }
}

class OngoingUniqueExerciseGroupWidget extends StatelessWidget {
  final ExerciseGroupTrainingSessionModel exerciseGroup;
  final void Function(ExerciseGroupTrainingSessionModel exerciseGroup)? onChanged;
  final VoidCallback onRemove;

  ExerciseTrainingSessionModel get exercise => exerciseGroup.exercises.first;

  const OngoingUniqueExerciseGroupWidget({
    super.key,
    required this.exerciseGroup,
    this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CSafeViewListWidget(
        horizontalPadding: 16,
        topPadding: -8,
        children: [
          IconButton(
              onPressed: () {
                context.push((context) => OngoingExerciseGroupeSettingsScreen(
                      onAddSimpleSet: () {
                        onChanged?.call(exerciseGroup.addSimpleSet());
                      },
                      onAddMultipleSet: () {
                        onChanged?.call(exerciseGroup.addMultipleSet());
                      },
                      onRemove: () {
                        onRemove.call();
                      },
                    ));
              },
              icon: const Icon(Icons.settings)),
          Text(
            exercise.exercise.getName(context),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          ...exercise.groupSets
              .map<Widget>(
                (e) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Gap(4),
                        Text(
                          AppLocale.labelSetN.getTranslation(context).replaceAll('%setnumber%', e.order.toString()),
                        ),
                        if (e.sets.isNotEmpty && e.sets.every((element) => element.done)) ...[
                          const Gap(4),
                          Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                        ]
                      ],
                    ),
                    Column(children: [
                      ...e.sets
                          .map<Widget>(
                            (eSet) => CSingleSetWidget(
                              editable: true,
                              onRemove: () {
                                onChanged?.call(
                                  exerciseGroup.changeAndValidate(
                                    exercises: [
                                      exercise.changeAndValidate(
                                        groupSets: exercise.groupSets
                                            .replaceWith(
                                              e,
                                              e.copyWith(
                                                sets: [...e.sets]..removeWhere((p0) => eSet.syncId == p0.syncId),
                                              ),
                                            )
                                            .toList(),
                                      )
                                    ],
                                  ),
                                );
                              },
                              onChanged: (p0) {
                                onChanged?.call(
                                  exerciseGroup.changeAndValidate(
                                    exercises: [
                                      exercise.changeAndValidate(
                                        groupSets: exercise.groupSets
                                            .replaceWith(
                                              e,
                                              e.copyWith(
                                                sets: e.sets.replaceFirstWhere((eSet) => eSet.syncId == p0.syncId, p0).toList(),
                                              ),
                                            )
                                            .toList(),
                                      )
                                    ],
                                  ),
                                );
                              },
                              exerciseSet: eSet,
                              order: eSet.order,
                            ),
                          )
                          .addBetween(const Gap(2)),
                      if (e.groupType == ExerciseSetGroupTypeEnum.multiple)
                        TextButton(
                          onPressed: () {
                            onChanged?.call(
                              exerciseGroup.changeAndValidate(
                                exercises: [
                                  exercise.changeAndValidate(
                                    groupSets: exercise.groupSets
                                        .replaceWith(
                                          e,
                                          e.addInnerSet(),
                                        )
                                        .toList(),
                                  )
                                ],
                              ),
                            );
                          },
                          child: Text(AppLocale.labelAddInnerSet.getTranslation(context)),
                        )
                    ])
                  ],
                ),
              )
              .addBetween(const Gap(16))
        ],
      ),
    );
  }
}
