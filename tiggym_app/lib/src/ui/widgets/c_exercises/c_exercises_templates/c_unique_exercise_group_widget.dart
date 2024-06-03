import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../../util/extensions/build_context_extensions.dart';
import '../../c_reorder_sets/c_reorder_sets_widget.dart';
import '../../c_tag_item/c_tag_item_widget.dart';
import 'c_unique_exercise_group_sets_widget.dart';

class CUniqueExerciseTemplateGroupWidget extends StatefulWidget {
  final ExerciseGroupTrainingTemplateModel exerciseGroup;
  final bool editable;
  final void Function(ExerciseGroupTrainingTemplateModel exerciseGroup)? onChanged;
  final VoidCallback? onRemove;
  const CUniqueExerciseTemplateGroupWidget({
    super.key,
    required this.exerciseGroup,
    this.editable = false,
    this.onChanged,
    this.onRemove,
  });

  @override
  State<CUniqueExerciseTemplateGroupWidget> createState() => _CUniqueExerciseTemplateGroupWidgetState();
}

class _CUniqueExerciseTemplateGroupWidgetState extends State<CUniqueExerciseTemplateGroupWidget> {
  @override
  Widget build(BuildContext context) {
    final tag = widget.exerciseGroup.exercises.first.exercise.tag;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                  ),
                  child: Text(
                    widget.exerciseGroup.exercises.first.exercise.getName(context),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (widget.editable) ...[
                const Gap(8),
                InkWell(
                  onTap: () {
                    showOptions();
                  },
                  borderRadius: BorderRadius.circular(80),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.more_vert,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Gap(4),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    tag != null ? CTagItemWidget(tag: tag, backgroundColor: Theme.of(context).colorScheme.surfaceVariant) : const SizedBox(),
                  ],
                ),
                const Gap(16),
                CUniqueExerciseGroupSetsWidget(
                  exerciseGroup: widget.exerciseGroup,
                  editable: widget.editable,
                  onChanged: widget.onChanged,
                ),
              ],
            ),
          ),
          const Gap(8),
        ],
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
            leading: const Icon(Icons.reorder, size: 12),
            onTap: () async {
              context.pop();
              final reordered = await context.showMaterialModalBottomSheet((context) => CReorderSetsWidget(sets: widget.exerciseGroup.exercises.first.groupSets));
              if (reordered != null) {
                widget.onChanged?.call(widget.exerciseGroup.copyWith(exercises: [widget.exerciseGroup.exercises.first.copyWith(groupSets: reordered)]));
              }
            },
            title: Text(AppLocale.labelReorderSets.getTranslation(context)),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.add, size: 12),
            onTap: () {
              context.pop();
              widget.onChanged?.call(widget.exerciseGroup.addSimpleSet());
            },
            title: Text(AppLocale.labelAddSimpleSet.getTranslation(context)),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.add, size: 12),
            onTap: () {
              context.pop();
              widget.onChanged?.call(widget.exerciseGroup.addMultipleSet());
            },
            title: Text(AppLocale.labelAddMultipleSet.getTranslation(context)),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.remove, size: 12),
            onTap: () {
              context.pop();
              widget.onRemove?.call();
            },
            title: Text(AppLocale.labelRemove.getTranslation(context)),
          ),
        ],
      ),
    );
  }
}
