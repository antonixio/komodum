import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../controllers/training_session_controller.dart';
import '../../../data/repository/training_template_repository/training_template_repository.dart';
import '../../../data/repository/training_template_repository/training_template_resume_repository.dart';
import '../../../util/extensions/build_context_extensions.dart';
import '../../widgets/c_confirmation_dialog/c_confirmation_dialog_widget.dart';
import '../../widgets/c_empty_message/c_empty_message_widget.dart';
import '../../widgets/c_training_template_item/c_training_template_item_widget.dart';
import '../training_session/edit_training_session_screen.dart';
import 'edit_training_template_screen.dart';

class TrainingTemplatesScreen extends StatefulWidget {
  const TrainingTemplatesScreen({super.key});

  @override
  State<TrainingTemplatesScreen> createState() => _TrainingTemplatesScreenState();
}

class _TrainingTemplatesScreenState extends State<TrainingTemplatesScreen> {
  final trainingTemplateResumeRepository = GetIt.I.get<TrainingTemplateResumeRepository>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          actions: [
            IconButton(
              onPressed: () async {
                await context.push((context) => const EditTrainingTemplateScreen());
                trainingTemplateResumeRepository.load();
              },
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: StreamBuilder(
            stream: trainingTemplateResumeRepository.data,
            initialData: trainingTemplateResumeRepository.data.value,
            builder: (context, snapshot) {
              final data = (snapshot.data ?? <TrainingTemplateResumeModel>[]).where((element) => element.deletedAt == null).toList();

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                children: [
                  if (data.isEmpty)
                    CEmptyMessageWidget(
                      title: AppLocale.messageNothingHereYet.getTranslation(context),
                      subtitle: AppLocale.messageCreateANewWorkout.getTranslation(context),
                    ),
                  ...data
                      .map<Widget>(
                        (e) => CTrainingTemplateItemWidget(
                          trainingTemplateResume: e,
                          onTap: () => edit(e),
                          onLongPress: () => showOptions(e),
                        ),
                      )
                      .addBetween(const Gap(16))
                      .toList(),
                ],
              );
            }),
      ),
    );
  }

  Future<void> edit(TrainingTemplateResumeModel e) async {
    context.loaderOverlay.show();
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final trainings = await GetIt.I.get<TrainingTemplateRepository>().getTrainings(id: e.id);
      final training = trainings.firstOrNull;
      // ignore: use_build_context_synchronously
      context.loaderOverlay.hide();

      // ignore: use_build_context_synchronously
      await context.push((context) => EditTrainingTemplateScreen(
            training: training,
          ));
      trainingTemplateResumeRepository.load();
    } finally {
      // ignore: use_build_context_synchronously
      context.loaderOverlay.hide();
    }
  }

  Future<void> showOptions(TrainingTemplateResumeModel e) async {
    context.showMaterialModalBottomSheet(
      (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        children: [
          ListTile(
            dense: true,
            onTap: () async {
              context.pop();
              edit(e);
            },
            leading: const Icon(Icons.edit, size: 12),
            title: Text(AppLocale.labelEdit.getTranslation(context)),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.play_arrow, size: 12),
            onTap: () async {
              context.pop();
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
              context.loaderOverlay.show();
              await Future.delayed(const Duration(milliseconds: 200));
              try {
                final trainings = await GetIt.I.get<TrainingTemplateRepository>().getTrainings(id: e.id);
                final training = trainings.firstOrNull;
                // ignore: use_build_context_synchronously
                context.loaderOverlay.hide();
                // ignore: use_build_context_synchronously
                context.popWhileCan();

                if (training != null) {
                  // ignore: use_build_context_synchronously
                  context.push((context) => EditTrainingSessionScreen(
                        trainingSession: training.toSession(),
                      ));
                }
              } finally {
                // ignore: use_build_context_synchronously
                context.loaderOverlay.hide();
              }
            },
            title: Text(AppLocale.labelStartWorkoutSession.getTranslation(context)),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.delete, size: 16),
            textColor: Theme.of(context).colorScheme.error,
            iconColor: Theme.of(context).colorScheme.error,
            title: Text(AppLocale.labelDelete.getTranslation(context)),
            onTap: () async {
              context.pop();
              bool confirm = await CConfirmationDialogWidget.show(
                context: context,
                message: AppLocale.labelConfirmGenericDeletion.getTranslation(context),
              );

              if (confirm) {
                await GetIt.I.get<TrainingTemplateRepository>().delete(e.id);
                trainingTemplateResumeRepository.load();
              }
            },
          )
        ],
      ),
    );
  }
}
