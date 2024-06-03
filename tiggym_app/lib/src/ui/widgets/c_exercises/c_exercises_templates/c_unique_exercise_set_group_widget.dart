import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import 'c_single_set_widget.dart';

class CUniqueExerciseGroupSetGroupWidget extends StatefulWidget {
  final ExerciseSetGroupTrainingTemplateModel exerciseSetGroup;
  final bool editable;
  final void Function(ExerciseSetGroupTrainingTemplateModel exerciseSetGroup)? onChanged;

  const CUniqueExerciseGroupSetGroupWidget({
    super.key,
    required this.exerciseSetGroup,
    this.editable = false,
    this.onChanged,
  });

  @override
  State<CUniqueExerciseGroupSetGroupWidget> createState() => _CUniqueExerciseGroupSetGroupWidgetState();
}

class _CUniqueExerciseGroupSetGroupWidgetState extends State<CUniqueExerciseGroupSetGroupWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.exerciseSetGroup.groupType == ExerciseSetGroupTypeEnum.unique) {
      return _buildUniqueSet();
    }

    if (widget.exerciseSetGroup.groupType == ExerciseSetGroupTypeEnum.multiple) {
      return _buildMultipleSet();
    }
    return const Text("Error");
  }

  Widget _buildUniqueSet() {
    return CSingleSetWidget(
      order: widget.exerciseSetGroup.order,
      exerciseSet: widget.exerciseSetGroup.sets.first,
      editable: widget.editable,
      onChanged: (newSet) {
        widget.onChanged?.call(widget.exerciseSetGroup.updateSet(widget.exerciseSetGroup.sets.first, newSet));
      },
      onRemove: () {
        widget.onChanged?.call(widget.exerciseSetGroup.removeSet(widget.exerciseSetGroup.sets.first));
      },
    );
  }

  Widget _buildMultipleSet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Gap(4),
        IntrinsicHeight(
          child: Row(
            children: [
              Center(
                child: SizedBox(
                  width: 30,
                  child: Text(
                    '${widget.exerciseSetGroup.order}.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                width: 4,
              ),
              const Gap(8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.exerciseSetGroup.sets
                      .map<Widget>(
                        (e) => CSingleSetWidget(
                          exerciseSet: e,
                          order: e.order,
                          editable: widget.editable,
                          onChanged: (newSet) {
                            widget.onChanged?.call(widget.exerciseSetGroup.updateSet(e, newSet));
                          },
                          onRemove: () {
                            widget.onChanged?.call(widget.exerciseSetGroup.removeSet(e));
                          },
                        ),
                      )
                      .addBetween(const Gap(4))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        if (widget.editable)
          TextButton(
            onPressed: () {
              widget.onChanged?.call(widget.exerciseSetGroup.addInnerSet());
            },
            child: Text(AppLocale.labelAddInnerSet.getTranslation(context)),
          )
      ],
    );
  }
}
