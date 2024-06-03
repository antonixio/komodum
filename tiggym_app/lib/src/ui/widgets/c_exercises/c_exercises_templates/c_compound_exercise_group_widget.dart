import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../../util/extensions/build_context_extensions.dart';
import '../../../screens/exercises/exercises_screen.dart';
import '../../c_reorder_exercises_compound/c_reorder_exercises_compound_widget.dart';
import '../../c_reorder_sets_compound/c_reorder_sets_compound_widget.dart';
import 'c_single_set_widget.dart';

class CCompoundExerciseTemplateGroupWidget extends StatefulWidget {
  final ExerciseGroupTrainingTemplateModel exerciseGroup;
  final bool editable;
  final void Function(ExerciseGroupTrainingTemplateModel exerciseGroup)? onChanged;
  final VoidCallback onRemove;
  const CCompoundExerciseTemplateGroupWidget({
    super.key,
    required this.exerciseGroup,
    this.editable = false,
    this.onChanged,
    required this.onRemove,
  });

  @override
  State<CCompoundExerciseTemplateGroupWidget> createState() => _CCompoundExerciseTemplateGroupWidgetState();
}

class _CCompoundExerciseTemplateGroupWidgetState extends State<CCompoundExerciseTemplateGroupWidget> {
  @override
  Widget build(BuildContext context) {
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
                    AppLocale.labelCompound.getTranslation(context),
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.exerciseGroup.exercises
                  .map<Widget>(
                    (e) => Row(
                      children: [
                        Expanded(
                          child: Text(
                            "- ${e.exercise.getName(context)}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (widget.editable)
                          InkWell(
                              onTap: () {
                                widget.onChanged?.call(widget.exerciseGroup.removeExercise(e));
                              },
                              borderRadius: BorderRadius.circular(80),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.close,
                                  size: 12,
                                ),
                              )),
                      ],
                    ),
                  )
                  .addBetween(const Gap(4))
                  .toList(),
            ),
          ),
          const Gap(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(
                widget.exerciseGroup.exercises.firstOrNull?.groupSets.length ?? 0,
                (index) => CCompoundExerciseSetGroupWidget(
                  order: index + 1,
                  exerciseGroup: widget.exerciseGroup,
                  onChanged: (exerciseSetGroup) {
                    widget.onChanged?.call(exerciseSetGroup);
                  },
                ),
              ).addBetween(const Gap(16)).toList(),
            ),
          ),
          const Gap(16),
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
          if (widget.exerciseGroup.exercises.isNotEmpty)
            ListTile(
              dense: true,
              leading: const Icon(Icons.reorder, size: 12),
              onTap: () async {
                context.pop();
                final reordered = await context.showMaterialModalBottomSheet((context) => CReorderExercisesCompoundWidget(exercises: widget.exerciseGroup.exercises));
                if (reordered != null) {
                  widget.onChanged?.call(widget.exerciseGroup.copyWith(exercises: reordered));
                }
              },
              title: Text(AppLocale.labelReorderExercises.getTranslation(context)),
            ),
          if (widget.exerciseGroup.exercises.firstOrNull?.groupSets.isNotEmpty ?? false)
            ListTile(
              dense: true,
              leading: const Icon(Icons.reorder, size: 12),
              onTap: () async {
                context.pop();
                final reordered = await context.showMaterialModalBottomSheet((context) => CReorderSetsCompoundWidget(exerciseGroup: widget.exerciseGroup));
                if (reordered != null) {
                  widget.onChanged?.call(reordered);
                }
              },
              title: Text(AppLocale.labelReorderSets.getTranslation(context)),
            ),
          if (widget.exerciseGroup.exercises.isNotEmpty)
            ListTile(
              dense: true,
              leading: const Icon(Icons.add, size: 12),
              onTap: () async {
                context.pop();
                widget.onChanged?.call(widget.exerciseGroup.addMultipleSet(quantity: 1));
              },
              title: Text(AppLocale.labelAddSet.getTranslation(context)),
            ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.add, size: 12),
            onTap: () async {
              context.pop();
              final exercise = await context.push((context) => const ExercisesScreen(isSelection: true));
              if (exercise != null && exercise is ExerciseModel) {
                widget.onChanged?.call(widget.exerciseGroup.addExercise(exercise));
              }
            },
            title: Text(AppLocale.labelAddExercise.getTranslation(context)),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.remove, size: 12),
            onTap: () {
              context.pop();
              widget.onRemove.call();
            },
            title: Text(AppLocale.labelRemove.getTranslation(context)),
          ),
        ],
      ),
    );
  }
}

class CCompoundExerciseSetGroupWidget extends StatelessWidget {
  final int order;
  final ExerciseGroupTrainingTemplateModel exerciseGroup;

  final void Function(ExerciseGroupTrainingTemplateModel exerciseSetGroup)? onChanged;
  const CCompoundExerciseSetGroupWidget({
    super.key,
    required this.order,
    required this.exerciseGroup,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocale.labelSetN.getTranslation(context).replaceAll('%setnumber%', order.toString()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            InkWell(
                onTap: () {
                  onChanged?.call(
                    exerciseGroup.copyWith(
                      exercises: exerciseGroup.exercises
                          .map(
                            (e) => e.copyWith(
                              groupSets: [...e.groupSets]..removeAt(order - 1),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(80),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.close,
                    size: 12,
                  ),
                )),
          ],
        ),
        const Gap(8),
        Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
              border: Border(
                left: BorderSide(color: Theme.of(context).colorScheme.surfaceVariant, width: 4),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: exerciseGroup.exercises
                  .map<Widget>(
                    (e) {
                      final groupSets = e.groupSets.elementAt(order - 1);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e.exercise.getName(context),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Gap(8),
                              InkWell(
                                onTap: () {
                                  onChanged?.call(
                                    exerciseGroup.changeAndValidate(
                                      exercises: exerciseGroup.exercises
                                          .replaceWith(
                                            e,
                                            e.changeAndValidate(
                                              groupSets: e.groupSets
                                                  .replaceWith(
                                                    groupSets,
                                                    groupSets.addInnerSet(),
                                                  )
                                                  .toList(),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(80),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.add,
                                    size: 12,
                                  ),
                                ),
                              ),
                              const Gap(4),
                            ],
                          ),
                          const Gap(2),
                          ...groupSets.sets
                              .map<Widget>(
                                (eSet) => Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: CSingleSetWidget(
                                    exerciseSet: eSet,
                                    order: eSet.order,
                                    editable: true,
                                    onChanged: (newSet) {
                                      onChanged?.call(
                                        exerciseGroup.changeAndValidate(
                                          exercises: exerciseGroup.exercises
                                              .replaceWith(
                                                e,
                                                e.changeAndValidate(
                                                  groupSets: e.groupSets
                                                      .replaceWith(
                                                        groupSets,
                                                        groupSets.updateSet(eSet, newSet),
                                                      )
                                                      .toList(),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      );
                                    },
                                    onRemove: groupSets.sets.length > 1
                                        ? () {
                                            onChanged?.call(
                                              exerciseGroup.changeAndValidate(
                                                exercises: exerciseGroup.exercises
                                                    .replaceWith(
                                                      e,
                                                      e.changeAndValidate(
                                                        groupSets: e.groupSets
                                                            .replaceWith(
                                                              groupSets,
                                                              groupSets.removeSet(eSet),
                                                            )
                                                            .toList(),
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            );
                                          }
                                        : null,
                                  ),
                                ),
                              )
                              .addBetween(const Gap(4))
                        ],
                      );
                    },
                  )
                  .addBetween(const Gap(10))
                  .toList(),
            ))
      ],
    );
  }
}
