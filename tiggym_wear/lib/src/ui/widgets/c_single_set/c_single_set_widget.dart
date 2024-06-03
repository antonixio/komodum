import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/ui/screens/ongoing_training/ongoing_exercise_set_screen.dart';
import 'package:tiggym_wear/src/ui/widgets/c_selectors/c_reps_selector/c_reps_selector.dart';
import 'package:tiggym_wear/src/util/extensions/build_context_extensions.dart';

import '../c_small_field_container/c_small_field_container.dart';

// import '../../../../util/extensions/build_context_extensions.dart';
// import '../../c_selectors/c_distance_selector/c_distance_selector.dart';
// import '../../c_selectors/c_reps_and_weight_selector/c_reps_and_weight_selector.dart';
// import '../../c_selectors/c_reps_selector/c_reps_selector.dart';
// import '../../c_selectors/c_time_and_distance_selector/c_time_and_distance_selector.dart';
// import '../../c_selectors/c_time_selector/c_time_selector.dart';
// import '../../c_small_field_container/c_small_field_container.dart';

class CSingleSetWidget extends StatefulWidget {
  final ExerciseSetTrainingSessionModel exerciseSet;
  final int order;
  final bool editable;
  final VoidCallback? onRemove;
  final void Function(ExerciseSetTrainingSessionModel)? onChanged;

  const CSingleSetWidget({
    super.key,
    required this.exerciseSet,
    required this.order,
    this.onRemove,
    this.editable = false,
    this.onChanged,
  });

  @override
  State<CSingleSetWidget> createState() => _CSingleSetWidgetState();
}

class _CSingleSetWidgetState extends State<CSingleSetWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push(
            (context) => OngoingExerciseSetScreen(
              exerciseSet: widget.exerciseSet,
              onChanged: widget.onChanged,
              onRemove: widget.onRemove,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              if (widget.editable)
                Checkbox.adaptive(
                  value: widget.exerciseSet.done,
                  onChanged: (v) {
                    widget.onChanged?.call(widget.exerciseSet.copyWith(done: v));
                  },
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                ),
              Expanded(child: _buildMeta()),
              const Gap(4),
            ],
          ),
        ),
      ),
    );
  }

  void onChangeMeta(ExerciseSetMetaTrainingSessionModel meta) {
    widget.onChanged?.call(widget.exerciseSet.copyWith(meta: meta));
  }

  Widget _buildMeta() {
    final meta = widget.exerciseSet.meta;

    return Row(
      children: [
        Text(
          meta.getFormatted(context),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
