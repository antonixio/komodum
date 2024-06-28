import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tiggym/src/data/repository/training_template_repository/training_template_resume_repository.dart';
import 'package:tiggym/src/ui/screens/training_session/finished_workout_stats_screen.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rxdart/rxdart.dart';
import '../../../controllers/training_session_controller.dart';
import '../../../data/repository/training_session_repository/training_session_repository.dart';
import '../../../data/repository/training_template_repository/training_template_repository.dart';
import '../../../util/extensions/build_context_extensions.dart';
import '../../widgets/c_confirmation_dialog/c_confirmation_dialog_widget.dart';
import '../../widgets/c_exercises/c_exercises_sessions/c_compound_exercise_group_widget.dart';
import '../../widgets/c_exercises/c_exercises_sessions/c_unique_exercise_group_widget.dart';
import '../../widgets/c_reorder_exercises/c_reorder_exercises_widget.dart';
import '../../widgets/c_selectors/c_date_time_selector/c_date_time_selector.dart';
import '../../widgets/c_selectors/c_duration_selector/c_duration_selector.dart';
import '../exercises/exercises_screen.dart';

class EditTrainingSessionScreen extends StatefulWidget {
  final TrainingSessionModel trainingSession;
  final bool newSession;
  const EditTrainingSessionScreen({
    super.key,
    required this.trainingSession,
    this.newSession = true,
  });

  @override
  State<EditTrainingSessionScreen> createState() => _EditTrainingSessionScreenState();
}

class _EditTrainingSessionScreenState extends State<EditTrainingSessionScreen> {
  final trainingSessionController = GetIt.I.get<TrainingSessionController>();
  late final BehaviorSubject<TrainingSessionModel> _trainingSession = BehaviorSubject.seeded(widget.trainingSession);
  ValueStream<TrainingSessionModel> get trainingSession => _trainingSession;
  final TrainingSessionRepository trainingRepository = GetIt.I.get();
  final TrainingTemplateRepository trainingTemplateRepository = GetIt.I.get();

  final List<StreamSubscription> subscriptions = [];
  @override
  void initState() {
    super.initState();
    if (widget.newSession) {
      trainingSessionController.updateOngoing(_trainingSession.value);

      subscriptions.add(trainingSessionController.ongoingSession.listen((event) {
        if (event != null) {
          _trainingSession.add(event);
        }
      }));

      subscriptions.add(trainingSessionController.popOngoingTraining.listen((event) {
        context.pop(true);
      }));
    }
  }

  void _updateTrainingSession(TrainingSessionModel training) {
    _trainingSession.add(training);
    trainingSessionController.updateOngoing(training);
  }

  @override
  void dispose() {
    for (var sub in subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          leading: IconButton(
            onPressed: () async {
              context.pop();
            },
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          title: StreamBuilder(
              stream: trainingSession,
              initialData: trainingSession.value,
              builder: (context, snapshot) {
                final data = snapshot.data!;
                return TextFormField(
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                  // readOnly: exercise.value.fromApp,
                  initialValue: data.name,
                  onChanged: (v) {
                    _updateTrainingSession(trainingSession.value.copyWith(name: v));
                  },
                  validator: (v) {
                    if (trainingSession.value.name.trim().isEmpty) {
                      return AppLocale.labelRequired.getTranslation(context);
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "...",
                    border: InputBorder.none,
                  ),
                );
              }),
          actions: [
            if (widget.newSession)
              IconButton(
                onPressed: () async {
                  final confirm = !widget.newSession ||
                      await CConfirmationDialogWidget.show(
                        context: context,
                        message: AppLocale.messageCancelTrainingSession.getTranslation(context),
                        // message: AppLocale.messageChangingMainTagToNormalTag.getTranslation(context).replaceAll('%changingtag%', tag.value.name).replaceAll('%tagunder%', mainTag?.name ?? ''),
                      );

                  if (confirm) {
                    await Future.delayed(const Duration(milliseconds: 100));
                    trainingSessionController.cancelOngoingTrainingSession();
                    // ignore: use_build_context_synchronously
                    context.pop();
                  }
                },
                icon: const Icon(Icons.block),
              ),
            IconButton(
              onPressed: () async {
                final reordered = await context.showMaterialModalBottomSheet((context) => CReorderExercisesWidget(exercises: trainingSession.value.exercises));

                if (reordered != null) {
                  _updateTrainingSession(trainingSession.value.copyWith(exercises: reordered));
                }
              },
              icon: const Icon(Icons.reorder),
            ),
            IconButton(
              onPressed: () {
                context.showMaterialModalBottomSheet((_) => CTrainingSessionFinishResumeWidget(
                    trainingSession: trainingSession.value.copyWith(duration: Duration(seconds: DateTime.now().secondsSinceEpoch - trainingSession.value.date.secondsSinceEpoch)),
                    ownerContext: context,
                    onSave: (updatedSession) async {
                      final session = trainingSession.value;
                      final ongoingSession = trainingSessionController.ongoingSession.value;
                      try {
                        context.loaderOverlay.show();

                        if (ongoingSession?.syncId == session.syncId) {
                          final tSession = trainingSessionController.ongoingSession.value?.copyWith(
                            date: updatedSession.date,
                            name: updatedSession.name,
                            duration: updatedSession.duration,
                          );

                          if (tSession != null) {
                            trainingSessionController.updateOngoing(tSession);
                          }
                          final sessionId = await trainingSessionController.finishOngoingTraining();
                          context.loaderOverlay.hide();

                          await context.showMaterialModalBottomSheet(
                            (context) => ListView(
                              padding: const EdgeInsets.all(16),
                              shrinkWrap: true,
                              children: [
                                Text(
                                  session.trainingTemplateId != null ? AppLocale.labelSaveWorkoutModifications.getTranslation(context) : AppLocale.labelSaveNewWorkout.getTranslation(context),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const Gap(16),
                                Text(
                                  session.trainingTemplateId != null ? AppLocale.messageSaveWorkoutModifications.getTranslation(context) : AppLocale.messageSaveNewWorkout.getTranslation(context),
                                ),
                                const Gap(16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                                        onPressed: () {
                                          context.pop();
                                        },
                                        child: Text(AppLocale.labelCancel.getTranslation(context)),
                                      ),
                                    ),
                                    const Gap(16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          context.loaderOverlay.show();
                                          await Future.delayed(const Duration(seconds: 1));
                                          final template = session.toTemplate();
                                          if (template.id < 1) {
                                            final templateId = await trainingTemplateRepository.insert(template);
                                            await trainingRepository.updateTemplateId(sessionId!, templateId);
                                          } else {
                                            await trainingTemplateRepository.update(session.toTemplate());
                                          }
                                          GetIt.I.get<TrainingTemplateResumeRepository>().load();
                                          context.loaderOverlay.hide();
                                          context.pop();
                                        },
                                        child: Text(AppLocale.labelConfirm.getTranslation(context)),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );

                          if (sessionId != null) {
                            await context.showMaterialModalBottomSheet((context) => FinishedWorkoutStatsScreen(sessionId: sessionId));
                          }
                          // context.pop(true);
                        } else if ((session.id ?? 0) < 1) {
                          final sessionId = await trainingRepository.insert(session);
                          context.loaderOverlay.hide();
                          await context.showMaterialModalBottomSheet(
                            (context) => ListView(
                              padding: const EdgeInsets.all(16),
                              shrinkWrap: true,
                              children: [
                                Text(
                                  session.trainingTemplateId != null ? AppLocale.labelSaveWorkoutModifications.getTranslation(context) : AppLocale.labelSaveNewWorkout.getTranslation(context),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const Gap(16),
                                Text(
                                  session.trainingTemplateId != null ? AppLocale.messageSaveWorkoutModifications.getTranslation(context) : AppLocale.messageSaveNewWorkout.getTranslation(context),
                                ),
                                const Gap(16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                                        onPressed: () {
                                          context.pop();
                                        },
                                        child: Text(AppLocale.labelCancel.getTranslation(context)),
                                      ),
                                    ),
                                    const Gap(16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          context.loaderOverlay.show();
                                          await Future.delayed(const Duration(seconds: 1));
                                          final template = session.toTemplate();
                                          if (template.id < 1) {
                                            final templateId = await trainingTemplateRepository.insert(template);
                                            await trainingRepository.updateTemplateId(sessionId!, templateId);
                                          } else {
                                            await trainingTemplateRepository.update(session.toTemplate());
                                          }
                                          GetIt.I.get<TrainingTemplateResumeRepository>().load();
                                          context.loaderOverlay.hide();
                                          context.pop();
                                        },
                                        child: Text(AppLocale.labelConfirm.getTranslation(context)),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                          context.pop(true);
                        } else {
                          trainingRepository.update(trainingSession.value.copyWith(
                            date: updatedSession.date,
                            name: updatedSession.name,
                            duration: updatedSession.duration,
                          ));
                          context.loaderOverlay.hide();
                        }
                      } catch (err) {
                        print(err);
                        context.loaderOverlay.hide();
                      }
                      if (mounted) {
                        context.pop(true);
                      }
                    }));
              },
              icon: const Icon(Icons.check),
            ),
            // IconButton(
            //   onPressed: () {
            //     context.showMaterialModalBottomSheet(
            //       (_) => ListView(
            //         shrinkWrap: true,
            //         padding: const EdgeInsets.all(0),
            //         children: [
            //           ListTile(
            //             dense: true,
            //             leading: const Icon(Icons.check, size: 12),
            //             onTap: () async {
            //               context.pop();
            //               context.showMaterialModalBottomSheet((_) => CTrainingSessionFinishResumeWidget(
            //                   trainingSession: trainingSession.value.copyWith(duration: duration.value),
            //                   ownerContext: context,
            //                   onSave: () {
            //                     context.pop();
            //                     context.pop(true);
            //                   }));
            //               // if ((trainingSession.value.id ?? 0) <= 0) {
            //               //   context.loaderOverlay.show();
            //               //   await Future.delayed(const Duration(milliseconds: 200));
            //               //   try {
            //               //     await trainingRepository.insert(trainingSession.value);
            //               //   } finally {
            //               //     // ignore: use_build_context_synchronously
            //               //     context.loaderOverlay.hide();
            //               //     // ignore: use_build_context_synchronously
            //               //     context.pop(true);
            //               //   }
            //               // } else {
            //               //   context.loaderOverlay.show();
            //               //   await Future.delayed(const Duration(milliseconds: 200));
            //               //   try {
            //               //     await trainingRepository.update(trainingSession.value);
            //               //   } finally {
            //               //     // ignore: use_build_context_synchronously
            //               //     context.loaderOverlay.hide();
            //               //     // ignore: use_build_cont ext_synchronously
            //               //     context.pop(true);
            //               //   }
            //               // }
            //               // exercise.add(exercise.value.copyWith(type: e));

            //               // final confirm = !widget.newSession ||
            //               //     await CConfirmationDialogWidget.show(
            //               //       context: context,
            //               //       message: AppLocale.messageCancelTrainingSession.getTranslation(context),
            //               //       // message: AppLocale.messageChangingMainTagToNormalTag.getTranslation(context).replaceAll('%changingtag%', tag.value.name).replaceAll('%tagunder%', mainTag?.name ?? ''),
            //               //     );

            //               // if (confirm) {
            //               //   await Future.delayed(const Duration(milliseconds: 100));
            //               //   // ignore: use_build_context_synchronously
            //               //   context.pop();
            //               // }
            //             },
            //             title: Text(widget.newSession ? AppLocale.labelFinishWorkout.getTranslation(context) : AppLocale.labelSave.getTranslation(context)),
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            //   icon: const Icon(Icons.more_vert),
            // ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StreamBuilder(
                            stream: trainingSession,
                            initialData: trainingSession.value,
                            builder: (context, snapshot) {
                              final data = snapshot.data!;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                  ),
                                  const Gap(8),
                                  Text(data.date.format(AppLocale.formatDateTime.getTranslation(context)), style: Theme.of(context).textTheme.labelSmall),
                                ],
                              );
                            }),
                        const Gap(16),
                        StreamBuilder(
                            stream: Stream.periodic(Durations.medium2),
                            builder: (context, snapshot) {
                              final dur = Duration(seconds: DateTime.now().secondsSinceEpoch - trainingSession.value.date.secondsSinceEpoch);
                              final session = trainingSession.value;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    size: 16,
                                  ),
                                  const Gap(8),
                                  Text(
                                    (session.id ?? 0) < 1 ? dur.hoursMinutesSeconds : session.duration.hoursMinutesSeconds,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontFeatures: [const FontFeature.tabularFigures()],
                                    ),
                                  ),
                                  const Gap(16),
                                ],
                              );
                            }),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.showMaterialModalBottomSheet((context) => CSessionNotesWidget(
                            note: trainingSession.value.note?.note,
                            onChanged: (v) {
                              _updateTrainingSession((trainingSession.value.copyWith(note: () => trainingSession.value.note?.copyWith(note: v) ?? TrainingSessionNoteModel.dummy(note: v))));
                            },
                          ));
                    },
                    icon: const Icon(Icons.note_alt),
                  )
                ],
              ),
            ),
          ),
        ),
        // appBar: AppBar(
        //   forceMaterialTransparency: true,
        //   backgroundColor: Theme.of(context).colorScheme.background,
        //   actions: [
        //     IconButton(
        //       onPressed: () async {
        //         if (key.currentState!.validate()) {
        //           if (training.value.id <= 0) {
        //             context.loaderOverlay.show();
        //             await Future.delayed(const Duration(milliseconds: 200));
        //             try {
        //               await trainingRepository.insert(training.value);
        //             } finally {
        //               // ignore: use_build_context_synchronously
        //               context.loaderOverlay.hide();
        //               // ignore: use_build_context_synchronously
        //               context.pop();
        //             }
        //           } else {
        //             context.loaderOverlay.show();
        //             await Future.delayed(const Duration(milliseconds: 200));
        //             try {
        //               await trainingRepository.update(training.value);
        //             } finally {
        //               // ignore: use_build_context_synchronously
        //               context.loaderOverlay.hide();
        //               // ignore: use_build_context_synchronously
        //               context.pop();
        //             }
        //           }
        //         }
        //       },
        //       icon: const Icon(Icons.check),
        //     )
        //   ],
        // ),

        body: StreamBuilder(
            stream: trainingSession,
            initialData: trainingSession.value,
            builder: (context, snapshot) {
              final data = snapshot.data!;
              return Stack(
                children: [
                  Positioned.fill(
                    child: ListView(padding: const EdgeInsets.symmetric(horizontal: 32), children: [
                      const Gap(16),
                      ...data.exercises
                          .map<Widget>(
                            (e) => e.groupType == ExerciseGroupTypeEnum.unique
                                ? CUniqueExerciseSessionGroupWidget(
                                    exerciseGroup: e,
                                    editable: true,
                                    onRemove: () {
                                      _updateTrainingSession(trainingSession.value.changeAndValidate(exercises: [...trainingSession.value.exercises]..removeWhere((i) => e.syncId == i.syncId)));
                                    },
                                    onChanged: (newE) {
                                      _updateTrainingSession(trainingSession.value.changeAndValidate(exercises: trainingSession.value.exercises.replaceWith(e, newE).toList()));
                                    },
                                  )
                                : CCompoundExerciseSessionGroupWidget(
                                    exerciseGroup: e,
                                    editable: true,
                                    onRemove: () {
                                      _updateTrainingSession(trainingSession.value.changeAndValidate(exercises: [...trainingSession.value.exercises]..removeWhere((i) => e.syncId == i.syncId)));
                                    },
                                    onChanged: (newE) {
                                      _updateTrainingSession(trainingSession.value.changeAndValidate(exercises: trainingSession.value.exercises.replaceWith(e, newE).toList()));
                                    },
                                  ),
                          )
                          .addBetween(const Gap(16)),
                      const Gap(16),
                      ElevatedButton(
                        onPressed: showOptions,
                        child: Text(AppLocale.labelAddExercise.getTranslation(context)),
                      ),
                      const Gap(180),
                    ]),
                  ),
                  // Positioned(
                  //   bottom: 16,
                  //   left: 0,
                  //   right: 0,
                  //   child: Center(
                  //     child: Container(
                  //       decoration: BoxDecoration(
                  //         color: Theme.of(context).colorScheme.primary,
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       child: Stack(
                  //         children: [
                  //           Padding(
                  //             padding: const EdgeInsets.all(16.0),
                  //             child: Column(
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: [
                  //                 Row(
                  //                   mainAxisAlignment: MainAxisAlignment.center,
                  //                   mainAxisSize: MainAxisSize.min,
                  //                   children: [
                  //                     ElevatedButton(
                  //                       onPressed: () {},
                  //                       child: const Text("-10s"),
                  //                     ),
                  //                     const Gap(8),
                  //                     Text(
                  //                       "00:00:30",
                  //                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  //                         color: Theme.of(context).colorScheme.onPrimary,
                  //                         fontWeight: FontWeight.bold,
                  //                         fontFeatures: [
                  //                           const FontFeature.tabularFigures(),
                  //                         ],
                  //                       ),
                  //                     ),
                  //                     const Gap(8),
                  //                     ElevatedButton(
                  //                       onPressed: () {},
                  //                       child: const Text("+10s"),
                  //                     ),
                  //                     const Gap(24),
                  //                     IconButton(
                  //                       onPressed: () {},
                  //                       color: Theme.of(context).colorScheme.onPrimary,
                  //                       padding: const EdgeInsets.all(0),
                  //                       constraints: BoxConstraints.tight(const Size(36, 36)),
                  //                       iconSize: 20,
                  //                       visualDensity: VisualDensity.compact,
                  //                       icon: const Icon(
                  //                         Icons.close,
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              );
            }),
      ),
    );
  }

  Future<void> showOptions() async {
    context.showMaterialModalBottomSheet(
      (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        children: [
          ListTile(
            dense: true,
            onTap: () async {
              context.pop();
              final exercise = await context.push((context) => const ExercisesScreen(isSelection: true));
              if (exercise != null && exercise is ExerciseModel) {
                _updateTrainingSession(
                  trainingSession.value.addSimpleExercise(exercise),
                );
              }
            },
            title: Text(AppLocale.labelAddSimpleExercise.getTranslation(context)),
          ),
          ListTile(
            dense: true,
            onTap: () async {
              context.pop();
              final exercise = await context.push((context) => const ExercisesScreen(isSelection: true));
              if (exercise != null && exercise is ExerciseModel) {
                _updateTrainingSession(
                  trainingSession.value.addCompoundExercise(exercise),
                );
              }
            },
            title: Text(AppLocale.labelAddCompoundExercise.getTranslation(context)),
            subtitle: Text(AppLocale.labelAddCompoundExerciseSubtitle.getTranslation(context)),
          ),
        ],
      ),
    );
  }
}

class CTrainingSessionFinishResumeWidget extends StatefulWidget {
  final TrainingSessionModel trainingSession;
  final BuildContext ownerContext;
  final void Function(TrainingSessionModel) onSave;
  const CTrainingSessionFinishResumeWidget({
    super.key,
    required this.trainingSession,
    required this.ownerContext,
    required this.onSave,
  });

  @override
  State<CTrainingSessionFinishResumeWidget> createState() => _CTrainingSessionFinishResumeWidgetState();
}

class _CTrainingSessionFinishResumeWidgetState extends State<CTrainingSessionFinishResumeWidget> {
  late final trainingSession = BehaviorSubject.seeded(widget.trainingSession);
  final GlobalKey<FormState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: StreamBuilder(
          stream: trainingSession,
          initialData: trainingSession.value,
          builder: (context, snapshot) {
            final data = snapshot.data!;
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                TextFormField(
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                  // readOnly: exercise.value.fromApp,
                  initialValue: data.name,
                  onChanged: (v) {
                    trainingSession.add(trainingSession.value.copyWith(name: v));
                  },
                  validator: (v) {
                    if (trainingSession.value.name.trim().isEmpty) {
                      return AppLocale.labelRequired.getTranslation(context);
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "...",
                    border: InputBorder.none,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(
                        Icons.timer_outlined,
                        size: 16,
                      ),
                      onPressed: () async {
                        context.pop();
                        final dur = await widget.ownerContext.showMaterialModalBottomSheet((context) => CDurationSelector(data: data.duration));
                        widget.ownerContext.showMaterialModalBottomSheet((context) => CTrainingSessionFinishResumeWidget(
                              trainingSession: trainingSession.value.copyWith(duration: dur),
                              ownerContext: widget.ownerContext,
                              onSave: widget.onSave,
                            ));
                      },
                      style: TextButton.styleFrom().copyWith(
                        padding: const MaterialStatePropertyAll(
                          EdgeInsets.all(4),
                        ),
                        visualDensity: VisualDensity.compact,
                        textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelSmall),
                      ),
                      label: Text(data.duration.hoursMinutesSeconds),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(
                        Icons.calendar_month,
                        size: 16,
                      ),
                      onPressed: () async {
                        context.pop();

                        final date = await widget.ownerContext.showMaterialModalBottomSheet((context) => CDateTimeSelector(date: data.date));
                        widget.ownerContext.showMaterialModalBottomSheet((context) => CTrainingSessionFinishResumeWidget(
                              trainingSession: trainingSession.value.copyWith(date: date),
                              ownerContext: widget.ownerContext,
                              onSave: widget.onSave,
                            ));
                      },
                      style: TextButton.styleFrom().copyWith(
                        padding: const MaterialStatePropertyAll(
                          EdgeInsets.all(4),
                        ),
                        visualDensity: VisualDensity.compact,
                        textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelSmall),
                      ),
                      label: Text(data.date.format(AppLocale.formatDateTime.getTranslation(context))),
                    ),
                  ],
                ),
                const Gap(16),
                ElevatedButton(
                  onPressed: () async {
                    if (key.currentState?.validate() ?? false) {
                      final training = trainingSession.value;

                      context.pop();
                      widget.onSave.call(training);
                    }
                  },
                  child: Text(AppLocale.labelSave.getTranslation(context)),
                ),
                const Gap(16),
                Gap(MediaQuery.of(context).viewInsets.bottom)
              ],
            );
          }),
    );
  }
}

class CSessionNotesWidget extends StatefulWidget {
  final String? note;
  final void Function(String) onChanged;
  const CSessionNotesWidget({
    super.key,
    this.note,
    required this.onChanged,
  });

  @override
  State<CSessionNotesWidget> createState() => _CSessionNotesWidgetState();
}

class _CSessionNotesWidgetState extends State<CSessionNotesWidget> {
  late String? note = widget.note;
  bool changed = false;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (changed) {
          widget.onChanged.call(note ?? '');
        }
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(0),
          children: [
            const Gap(16),
            const Icon(Icons.note_alt),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 300,
                child: TextFormField(
                  initialValue: widget.note,
                  onChanged: (v) {
                    changed = true;
                    note = v;
                  },
                  textAlignVertical: TextAlignVertical.top,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: "...\n...\n..."),
                ),
              ),
            ),
            const Gap(16),
            Gap(MediaQuery.of(context).viewInsets.bottom)
          ],
        ),
      ),
    );
  }
}
