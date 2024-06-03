import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/ui/screens/exercises/exercises_screen.dart';
import 'package:tiggym_wear/src/ui/widgets/c_safe_view_list/c_safe_view_list_widget.dart';
import 'package:tiggym_wear/src/util/extensions/build_context_extensions.dart';

class OngoingTrainingSettingsScreen extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onAddExercise;
  final VoidCallback onAddCompoundExercise;
  final VoidCallback onFinish;
  const OngoingTrainingSettingsScreen({
    super.key,
    required this.onCancel,
    required this.onAddExercise,
    required this.onAddCompoundExercise,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CSafeViewListWidget(
        children: [
          ElevatedButton.icon(
              onPressed: () async {
                context.pop();
                onAddExercise.call();
                // onAddSimpleSet.call();
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocale.labelAddExercise.getTranslation(context))),
          const Gap(4),
          ElevatedButton.icon(
              onPressed: () {
                context.pop();
                onAddCompoundExercise.call();
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocale.labelAddCompoundExercise.getTranslation(context))),
          const Gap(4),
          ElevatedButton.icon(
              onPressed: () {
                context.pop();
                onFinish.call();
              },
              icon: const Icon(Icons.check),
              label: Text(AppLocale.labelFinishWorkout.getTranslation(context))),
          const Gap(16),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                context.pop();
                onCancel.call();
              },
              icon: const Icon(Icons.block),
              label: Text(AppLocale.labelCancelWorkout.getTranslation(context))),
        ],
      ),
    );
  }
}
