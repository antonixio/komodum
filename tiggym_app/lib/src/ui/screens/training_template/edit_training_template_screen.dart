import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import '../../widgets/c_reorder_exercises/c_reorder_exercises_widget.dart';

import '../../../controllers/training_session_controller.dart';
import '../../../data/repository/training_template_repository/training_template_repository.dart';
import '../../../util/extensions/build_context_extensions.dart';
import '../../widgets/c_confirmation_dialog/c_confirmation_dialog_widget.dart';
import '../../widgets/c_exercises/c_exercises_templates/c_compound_exercise_group_widget.dart';
import '../../widgets/c_exercises/c_exercises_templates/c_unique_exercise_group_widget.dart';
import '../exercises/exercises_screen.dart';
import '../training_session/edit_training_session_screen.dart';

class EditTrainingTemplateScreen extends StatefulWidget {
  final TrainingTemplateModel? training;
  const EditTrainingTemplateScreen({
    super.key,
    this.training,
  });

  @override
  State<EditTrainingTemplateScreen> createState() => _EditTrainingTemplateScreenState();
}

class _EditTrainingTemplateScreenState extends State<EditTrainingTemplateScreen> {
  final TrainingTemplateRepository trainingRepository = GetIt.I.get();
  late final training = BehaviorSubject.seeded(widget.training ?? TrainingTemplateModel.dummy);
  final GlobalKey<FormState> key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          actions: [
            if (training.value.id >= 1)
              TextButton.icon(
                onPressed: () async {
                  if (GetIt.I.get<TrainingSessionController>().hasOngoingSession) {
                    if (!await CConfirmationDialogWidget.show(
                      context: context,
                      message: AppLocale.messageOngoingWorkoutSession.getTranslation(context),
                    )) {
                      return;
                    }
                    GetIt.I.get<TrainingSessionController>().cancelOngoingTrainingSession();
                  }
                  // ignore: use_build_context_synchronously
                  context.popWhileCan();

                  // ignore: use_build_context_synchronously
                  await context.push((context) => EditTrainingSessionScreen(
                        trainingSession: training.value.toSession(),
                      ));
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(AppLocale.labelStart.getTranslation(context)),
              ),
            IconButton(
              onPressed: () async {
                final reordered = await context.showMaterialModalBottomSheet((context) => CReorderExercisesWidget(exercises: training.value.exercises));

                if (reordered != null) {
                  training.add(training.value.copyWith(exercises: reordered));
                }
              },
              icon: const Icon(Icons.reorder),
            ),
            IconButton(
              onPressed: () async {
                if (key.currentState!.validate()) {
                  if (training.value.id <= 0) {
                    context.loaderOverlay.show();
                    await Future.delayed(const Duration(milliseconds: 200));
                    try {
                      await trainingRepository.insert(training.value);
                    } finally {
                      // ignore: use_build_context_synchronously
                      context.loaderOverlay.hide();
                      // ignore: use_build_context_synchronously
                      context.pop();
                    }
                  } else {
                    context.loaderOverlay.show();
                    await Future.delayed(const Duration(milliseconds: 200));
                    try {
                      await trainingRepository.update(training.value);
                    } finally {
                      // ignore: use_build_context_synchronously
                      context.loaderOverlay.hide();
                      // ignore: use_build_context_synchronously
                      context.pop();
                    }
                  }
                }
              },
              icon: const Icon(Icons.check),
            )
          ],
        ),
        body: StreamBuilder(
            stream: training,
            initialData: training.value,
            builder: (context, snapshot) {
              final data = snapshot.data!;
              return Form(
                key: key,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  children: [
                    TextFormField(
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                      initialValue: data.name,
                      onChanged: (v) {
                        training.add(training.value.copyWith(name: v));
                      },
                      validator: (v) {
                        if (training.value.name.trim().isEmpty) {
                          return AppLocale.labelRequired.getTranslation(context);
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: AppLocale.labelName.getTranslation(context),
                        border: InputBorder.none,
                      ),
                    ),
                    const Gap(16),
                    ...data.exercises
                        .map<Widget>(
                          (e) => e.groupType == ExerciseGroupTypeEnum.unique
                              ? CUniqueExerciseTemplateGroupWidget(
                                  exerciseGroup: e,
                                  editable: true,
                                  onRemove: () {
                                    training.add(training.value.changeAndValidate(exercises: [...training.value.exercises]..remove(e)));
                                  },
                                  onChanged: (newE) {
                                    training.add(training.value.changeAndValidate(exercises: training.value.exercises.replaceWith(e, newE).toList()));
                                  },
                                )
                              : CCompoundExerciseTemplateGroupWidget(
                                  exerciseGroup: e,
                                  editable: true,
                                  onRemove: () {
                                    training.add(training.value.changeAndValidate(exercises: [...training.value.exercises]..remove(e)));
                                  },
                                  onChanged: (newE) {
                                    training.add(training.value.changeAndValidate(exercises: training.value.exercises.replaceWith(e, newE).toList()));
                                  },
                                ),
                        )
                        .addBetween(const Gap(16)),
                    const Gap(16),
                    ElevatedButton(
                      onPressed: showOptions,
                      child: Text(AppLocale.labelAddExercise.getTranslation(context)),
                    ),
                    const Gap(16),
                  ],
                ),
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
            leading: const Icon(Icons.add, size: 12),
            onTap: () async {
              context.pop();
              final exercise = await context.push((context) => const ExercisesScreen(isSelection: true));
              if (exercise != null && exercise is ExerciseModel) {
                training.add(
                  training.value.addSimpleExercise(exercise),
                );
              }
            },
            title: Text(AppLocale.labelAddSimpleExercise.getTranslation(context)),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.add, size: 12),
            onTap: () async {
              context.pop();
              final exercise = await context.push((context) => const ExercisesScreen(isSelection: true));
              if (exercise != null && exercise is ExerciseModel) {
                training.add(
                  training.value.addCompoundExercise(exercise),
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
