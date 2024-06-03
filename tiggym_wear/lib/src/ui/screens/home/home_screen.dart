import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/data/repositories/training_session_repository.dart';
import 'package:tiggym_wear/src/data/repositories/training_template_repository.dart';
import 'package:tiggym_wear/src/ui/widgets/c_toast_container/c_toast_controller.dart';
import 'package:tiggym_wear/src/util/extensions/build_context_extensions.dart';

import '../../../util/services/wear_connectivity_service.dart';
import '../../widgets/c_safe_view_list/c_safe_view_list_widget.dart';
import '../ongoing_training/ongoing_training_screen.dart';

/// Button to go to current training
/// Button to trainings
/// Show available training templates
/// Button 🔥 Frequency
/// Show heatmap of frequency
/// Button Connected Device
/// Ask if want to disconnect on tap
///

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final syncing = BehaviorSubject.seeded(false);
  final trainingRepository = GetIt.I.get<TrainingSessionRepository>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CSafeViewListWidget(
        topPadding: -8,
        children: [
          StreamBuilder(
            stream: trainingRepository.currentSessions,
            builder: ((context, snapshot) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(8),
                  if (snapshot.data?.watchSession != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: COngoingTrainingSessionWidget(
                        onTap: () {
                          context.push((context) => const OngoingTrainingScreen());
                        },
                        trainingSession: snapshot.data!.watchSession!,
                        icon: Icons.play_circle_filled,
                        title: AppLocale.labelOngoingWorkout.getTranslation(context),
                      ),
                    ),
                    const Gap(16),
                  ],
                  if (snapshot.data?.phoneSession != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: COngoingTrainingSessionWidget(
                        trainingSession: snapshot.data!.phoneSession!,
                        icon: Icons.smartphone,
                        title: AppLocale.labelOnYourPhone.getTranslation(context),
                        onTap: () {},
                      ),
                    ),
                ],
              );
            }),
          ),
          StreamBuilder(
            stream: trainingRepository.syncMessages,
            initialData: trainingRepository.syncMessages.value,
            builder: (context, snapshot) {
              final data = snapshot.data ?? <List<SyncModel<SyncTrainingSessionModel>>>[];

              if (data.isNotEmpty) {
                return StreamBuilder(
                    stream: syncing,
                    initialData: syncing.value,
                    builder: (context, snapshot) {
                      final isSyncing = snapshot.data ?? false;

                      return Column(
                        children: [
                          const Gap(8),
                          ElevatedButton.icon(
                            icon: isSyncing
                                ? const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1))
                                : const Icon(
                                    Icons.sync,
                                    size: 16,
                                  ),
                            onPressed: isSyncing
                                ? null
                                : () {
                                    syncing.add(true);
                                    trainingRepository.syncPending();
                                    Future.delayed(const Duration(seconds: 30), () {
                                      syncing.add(false);
                                    });
                                  },
                            label: Text(AppLocale.labelSyncPendingData.getTranslation(context)),
                          ),
                          Text(
                            AppLocale.labelMakeSureYourDeviceIsConnectedAndNearby.getTranslation(context),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall,
                          )
                        ],
                      );
                    });
              }

              return const Gap(8);
            },
          ),
          StreamBuilder(
              stream: GetIt.I.get<TrainingTemplateRepository>().trainings,
              initialData: GetIt.I.get<TrainingTemplateRepository>().trainings.value,
              builder: (context, snapshot) {
                final data = snapshot.data;

                if (data == null) {
                  return Column(
                    children: [
                      Text(
                        AppLocale.messageCouldntGetWorkouts.getTranslation(context),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(4),
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    ],
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppLocale.labelWorkouts.getTranslation(context),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Gap(4),
                    ...data.map(
                      (e) => ElevatedButton(
                        onPressed: () {
                          final repo = GetIt.I.get<TrainingSessionRepository>();
                          if (repo.currentSessions.value.watchSession == null) {
                            repo.changeSession(e.toSession());
                            context.push((context) => const OngoingTrainingScreen());
                          } else {
                            GetIt.I.get<CToastController>().addText(text: AppLocale.messageFinishDiscardBefore.getTranslation(context));
                          }
                          // WearConnectivityService.instance.sendMessage(e.name);
                          // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OngoingTrainingScreen()));
                        },
                        // icon: const Icon(Icons.play_arrow),
                        child: Text(e.name),
                      ),
                    ),
                    if (data.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          AppLocale.messageCreateNewWorkoutsOnYourDevice.getTranslation(context),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    const Gap(8),
                  ],
                );
              }),
          const Gap(16),
          StreamBuilder(
            stream: WearConnectivityService.instance.connectedDevice,
            initialData: WearConnectivityService.instance.connectedDevice.value,
            builder: (context, snapshot) {
              final data = snapshot.data;
              return TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.exit_to_app),
                label: Text(AppLocale.labelDevice.getTranslation(context).replaceAll('%device%', data?.deviceName ?? '-')),
              );
            },
          )
        ],
      ),
    );
  }
}

class COngoingTrainingSessionWidget extends StatefulWidget {
  final TrainingSessionModel trainingSession;
  final IconData icon;
  final VoidCallback? onTap;
  final String title;
  const COngoingTrainingSessionWidget({
    super.key,
    required this.trainingSession,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  State<COngoingTrainingSessionWidget> createState() => _COngoingTrainingSessionWidgetState();
}

class _COngoingTrainingSessionWidgetState extends State<COngoingTrainingSessionWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    widget.icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                  const Gap(8),
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Gap(4),
              Text(
                widget.trainingSession.date.format(AppLocale.formatDateTime.getTranslation(context)),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
