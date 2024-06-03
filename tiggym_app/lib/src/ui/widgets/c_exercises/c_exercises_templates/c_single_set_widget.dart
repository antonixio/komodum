import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../../util/extensions/build_context_extensions.dart';
import '../../c_selectors/c_distance_selector/c_distance_selector.dart';
import '../../c_selectors/c_reps_and_weight_selector/c_reps_and_weight_selector.dart';
import '../../c_selectors/c_reps_selector/c_reps_selector.dart';
import '../../c_selectors/c_time_and_distance_selector/c_time_and_distance_selector.dart';
import '../../c_selectors/c_time_selector/c_time_selector.dart';
import '../../c_small_field_container/c_small_field_container.dart';

class CSingleSetWidget extends StatefulWidget {
  final ExerciseSetTrainingTemplateModel exerciseSet;
  final int order;
  final bool editable;
  final VoidCallback? onRemove;
  final void Function(ExerciseSetTrainingTemplateModel)? onChanged;

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
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            '${widget.order}.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: _buildMeta()),
        if (widget.editable && widget.onRemove != null)
          InkWell(
              onTap: widget.onRemove,
              borderRadius: BorderRadius.circular(80),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.close,
                  size: 12,
                ),
              )),
      ],
    );
  }

  void onChangeMeta(ExerciseSetMetaTrainingTemplateModel meta) {
    widget.onChanged?.call(widget.exerciseSet.copyWith(meta: meta));
  }

  Widget _buildMeta() {
    final meta = widget.exerciseSet.meta;

    if (meta is ExerciseSetMetaRepsTrainingTemplateModel) {
      return _buildReps(meta);
    }
    if (meta is ExerciseSetMetaRepsAndWeightTrainingTemplateModel) {
      return _buildRepsAndWeight(meta);
    }

    if (meta is ExerciseSetMetaTimeTrainingTemplateModel) {
      return _buildTime(meta);
    }

    if (meta is ExerciseSetMetaDistanceTrainingTemplateModel) {
      return _buildDistance(meta);
    }

    if (meta is ExerciseSetMetaTimeAndDistanceTrainingTemplateModel) {
      return _buildTimeAndDistance(meta);
    }

    return const Text("Error");
  }

  Widget _buildReps(ExerciseSetMetaRepsTrainingTemplateModel meta) {
    final tapHandler = widget.editable
        ? () async {
            final newMeta = await context.showMaterialModalBottomSheet((context) => CRepsSelector(data: meta));

            if (newMeta != null && newMeta is ExerciseSetMetaRepsTrainingTemplateModel) {
              onChangeMeta(newMeta);
            }
          }
        : null;
    return Row(
      children: [
        CSmallFieldContainer(
          text: meta.reps.toString(),
          onTap: tapHandler,
        ),
        const Gap(8),
        Text(AppLocale.labelReps.getTranslation(context)),
      ],
    );
  }

  Widget _buildRepsAndWeight(ExerciseSetMetaRepsAndWeightTrainingTemplateModel meta) {
    final tapHandler = widget.editable
        ? () async {
            final newMeta = await context.showMaterialModalBottomSheet((context) => CRepsAndWeightSelector(data: meta));

            if (newMeta != null && newMeta is ExerciseSetMetaRepsAndWeightTrainingTemplateModel) {
              onChangeMeta(newMeta);
            }
          }
        : null;
    return Row(
      children: [
        CSmallFieldContainer(text: meta.reps.toString(), onTap: tapHandler),
        const Gap(8),
        const Text('x', style: TextStyle(fontSize: 11)),
        const Gap(8),
        CSmallFieldContainer(text: meta.weight.toString(), onTap: tapHandler),
        const Gap(8),
        CSmallFieldContainer(text: meta.weightUnit.getLabel(context), onTap: tapHandler),
      ],
    );
  }

  Widget _buildTime(ExerciseSetMetaTimeTrainingTemplateModel meta) {
    final tapHandler = widget.editable
        ? () async {
            final newMeta = await context.showMaterialModalBottomSheet((context) => CTimeSelector(data: meta));

            if (newMeta != null && newMeta is ExerciseSetMetaTimeTrainingTemplateModel) {
              onChangeMeta(newMeta);
            }
          }
        : null;
    return Row(
      children: [
        CSmallFieldContainer(text: meta.duration.hoursMinutesSeconds, onTap: tapHandler),
      ],
    );
  }

  Widget _buildDistance(ExerciseSetMetaDistanceTrainingTemplateModel meta) {
    final tapHandler = widget.editable
        ? () async {
            final newMeta = await context.showMaterialModalBottomSheet((context) => CDistanceSelector(data: meta));

            if (newMeta != null && newMeta is ExerciseSetMetaDistanceTrainingTemplateModel) {
              onChangeMeta(newMeta);
            }
          }
        : null;
    return Row(
      children: [
        CSmallFieldContainer(
          text: "${meta.distance} ${meta.unit.getLabelShort(context)}",
          onTap: tapHandler,
        ),
      ],
    );
  }

  Widget _buildTimeAndDistance(ExerciseSetMetaTimeAndDistanceTrainingTemplateModel meta) {
    final tapHandler = widget.editable
        ? () async {
            final newMeta = await context.showMaterialModalBottomSheet((context) => CTimeAndDistanceSelector(data: meta));

            if (newMeta != null && newMeta is ExerciseSetMetaTimeAndDistanceTrainingTemplateModel) {
              onChangeMeta(newMeta);
            }
          }
        : null;
    return Row(
      children: [
        CSmallFieldContainer(text: "${meta.distance} ${meta.unit.getLabelShort(context)}", onTap: tapHandler),
        const Gap(8),
        const Text('-'),
        const Gap(8),
        CSmallFieldContainer(text: meta.duration.hoursMinutesSeconds, onTap: tapHandler),
      ],
    );
  }
}
