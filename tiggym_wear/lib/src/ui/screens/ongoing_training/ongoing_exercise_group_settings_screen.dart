import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/ui/widgets/c_safe_view_list/c_safe_view_list_widget.dart';
import 'package:tiggym_wear/src/util/extensions/build_context_extensions.dart';

class OngoingExerciseGroupeSettingsScreen extends StatelessWidget {
  final VoidCallback onRemove;
  final VoidCallback onAddSimpleSet;
  final VoidCallback onAddMultipleSet;
  const OngoingExerciseGroupeSettingsScreen({
    super.key,
    required this.onRemove,
    required this.onAddSimpleSet,
    required this.onAddMultipleSet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CSafeViewListWidget(
        children: [
          ElevatedButton.icon(
              onPressed: () {
                context.pop();
                onAddSimpleSet.call();
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocale.labelAddSimpleSet.getTranslation(context))),
          const Gap(4),
          ElevatedButton.icon(
              onPressed: () {
                context.pop();
                onAddMultipleSet.call();
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocale.labelAddMultipleSet.getTranslation(context))),
          const Gap(16),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: () {
                context.pop();
                onRemove.call();
              },
              icon: const Icon(Icons.remove),
              label: Text(AppLocale.labelRemove.getTranslation(context))),
        ],
      ),
    );
  }
}
