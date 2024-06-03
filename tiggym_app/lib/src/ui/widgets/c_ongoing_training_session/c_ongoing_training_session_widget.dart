import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../util/extensions/build_context_extensions.dart';
import '../../screens/training_session/edit_training_session_screen.dart';

class COngoingTrainingSessionWidget extends StatefulWidget {
  final TrainingSessionModel trainingSession;
  const COngoingTrainingSessionWidget({
    super.key,
    required this.trainingSession,
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
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      child: InkWell(
        onTap: () async {
          // ignore: use_build_context_synchronously
          await context.push((context) => EditTrainingSessionScreen(
                trainingSession: widget.trainingSession,
              ));
        },
        child: Row(
          children: [
            const Gap(16),
            Icon(
              Icons.play_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(16),
                  Text(
                    AppLocale.labelOngoingWorkout.getTranslation(context),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const Gap(8),
                  Text(
                    widget.trainingSession.name.isEmpty ? "..." : widget.trainingSession.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Gap(4),
                  Text(
                    widget.trainingSession.date.format(AppLocale.formatDateTime.getTranslation(context)),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const Gap(16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
