import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/data/model/weight_model.dart';
import 'package:tiggym_wear/src/ui/widgets/c_safe_view_list/c_safe_view_list_widget.dart';
import 'package:tiggym_wear/src/ui/widgets/c_selectors/c_reps_selector/c_reps_selector.dart';
import 'package:tiggym_wear/src/ui/widgets/c_selectors/c_time_selector/c_time_selector.dart';
import 'package:tiggym_wear/src/ui/widgets/c_selectors/c_double_selector/c_double_selector.dart';
import 'package:tiggym_wear/src/ui/widgets/c_selectors/c_weight_unit_selector/c_weight_unit_selector.dart';
import 'package:tiggym_wear/src/util/extensions/build_context_extensions.dart';

import '../../widgets/c_selectors/c_distance_unit_selector/c_distance_unit_selector.dart';
import '../../widgets/c_small_field_container/c_small_field_container.dart';

class OngoingExerciseSetScreen extends StatefulWidget {
  final ExerciseSetTrainingSessionModel exerciseSet;
  final void Function(ExerciseSetTrainingSessionModel)? onChanged;
  final VoidCallback? onRemove;

  const OngoingExerciseSetScreen({
    super.key,
    required this.exerciseSet,
    this.onChanged,
    this.onRemove,
  });

  @override
  State<OngoingExerciseSetScreen> createState() => _OngoingExerciseSetScreenState();
}

class _OngoingExerciseSetScreenState extends State<OngoingExerciseSetScreen> {
  late final exerciseSet = BehaviorSubject.seeded(widget.exerciseSet);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: exerciseSet,
          initialData: exerciseSet.value,
          builder: (context, snapshot) {
            final data = snapshot.data!;
            return CSafeViewListWidget(
              children: [
                Checkbox.adaptive(
                    value: data.done,
                    visualDensity: VisualDensity.compact,
                    onChanged: (v) {
                      final eSet = data.copyWith(done: v);
                      exerciseSet.add(eSet);
                      widget.onChanged?.call(eSet);
                    }),
                const Gap(2),
                _buildMeta(data),
                // Text(widget.exerciseSet.meta.getFormatted(context)),
                const Gap(16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  onPressed: () {
                    context.pop();
                    widget.onRemove?.call();
                  },
                  icon: const Icon(Icons.remove),
                  label: Text(AppLocale.labelDelete.getTranslation(context)),
                )
              ],
            );
          }),
    );
  }

  Widget _buildMeta(ExerciseSetTrainingSessionModel exerciseSet) {
    final meta = exerciseSet.meta;

    if (meta is ExerciseSetMetaRepsTrainingSessionModel) {
      return _buildReps(meta);
    }
    if (meta is ExerciseSetMetaRepsAndWeightTrainingSessionModel) {
      return _buildRepsAndWeight(meta);
    }

    if (meta is ExerciseSetMetaTimeTrainingSessionModel) {
      return _buildTime(meta);
    }

    if (meta is ExerciseSetMetaDistanceTrainingSessionModel) {
      return _buildDistance(meta);
    }

    if (meta is ExerciseSetMetaTimeAndDistanceTrainingSessionModel) {
      return _buildTimeAndDistance(meta);
    }

    return const Text("Error");
  }

  Widget _buildRepsAndWeight(ExerciseSetMetaRepsAndWeightTrainingSessionModel meta) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        CSmallFieldContainer(
          text: meta.reps.toString(),
          onTap: () async {
            final reps = await context.push((context) => CRepsSelector(data: meta.reps));

            if (reps != null && reps is int) {
              exerciseSet.add(exerciseSet.value.copyWith(meta: meta.copyWith(reps: reps)));
              widget.onChanged?.call(exerciseSet.value);
            }
          },
          title: AppLocale.labelReps.getTranslation(context),
        ),
        Text('x', style: Theme.of(context).textTheme.labelLarge),
        CSmallFieldContainer(
          text: meta.weight.toString(),
          onTap: () async {
            final weight = await context.push((context) => CDoubleSelector(data: meta.weight));
            if (weight != null && weight is double) {
              exerciseSet.add(exerciseSet.value.copyWith(meta: meta.copyWith(weight: weight)));
              widget.onChanged?.call(exerciseSet.value);
            }
          },
          title: AppLocale.labelWeight.getTranslation(context),
        ),
        CSmallFieldContainer(
            text: meta.weightUnit.getLabel(context),
            onTap: () async {
              final weightUnit = await context.push((context) => CWeightUnitSelector(data: meta.weightUnit));
              if (weightUnit != null && weightUnit is WeightUnitEnum) {
                exerciseSet.add(exerciseSet.value.copyWith(meta: meta.copyWith(weightUnit: weightUnit)));
                widget.onChanged?.call(exerciseSet.value);
              }
            },
            title: ''),
      ],
    );
  }

  Widget _buildReps(ExerciseSetMetaRepsTrainingSessionModel meta) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        CSmallFieldContainer(
            title: AppLocale.labelReps.getTranslation(context),
            text: meta.reps.toString(),
            onTap: () async {
              final reps = await context.push((_) => CRepsSelector(data: meta.reps));

              if (reps != null && reps is int) {
                exerciseSet.add(exerciseSet.value.copyWith(meta: meta.copyWith(reps: reps)));
                widget.onChanged?.call(exerciseSet.value);
              }
            }),
      ],
    );
  }

  Widget _buildTime(ExerciseSetMetaTimeTrainingSessionModel meta) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        CSmallFieldContainer(
          title: AppLocale.labelTime.getTranslation(context),
          text: meta.duration.hoursMinutesSeconds,
          onTap: () async {
            final duration = await context.push((_) => CTimeSelector(data: meta.duration));

            if (duration != null && duration is Duration) {
              exerciseSet.add(exerciseSet.value.copyWith(meta: meta.copyWith(duration: duration)));
              widget.onChanged?.call(exerciseSet.value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDistance(ExerciseSetMetaDistanceTrainingSessionModel meta) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        CSmallFieldContainer(
          title: AppLocale.labelDistance.getTranslation(context),
          text: meta.distance.toString(),
          onTap: () async {
            final distance = await context.push((context) => CDoubleSelector(data: meta.distance));
            if (distance != null && distance is double) {
              exerciseSet.add(exerciseSet.value.copyWith(meta: meta.copyWith(distance: distance)));
              widget.onChanged?.call(exerciseSet.value);
            }
          },
        ),
        CSmallFieldContainer(
          title: '',
          text: meta.unit.getLabelShort(context),
          onTap: () async {
            final distanceUnit = await context.push((context) => CDistanceUnitSelector(data: meta.unit));
            if (distanceUnit != null && distanceUnit is DistanceUnitEnum) {
              exerciseSet.add(exerciseSet.value.copyWith(meta: meta.copyWith(unit: distanceUnit)));
              widget.onChanged?.call(exerciseSet.value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTimeAndDistance(ExerciseSetMetaTimeAndDistanceTrainingSessionModel meta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CSmallFieldContainer(
          title: AppLocale.labelTime.getTranslation(context),
          text: meta.duration.hoursMinutesSeconds,
          onTap: () async {
            final duration = await context.push((_) => CTimeSelector(data: meta.duration));

            if (duration != null && duration is Duration) {
              exerciseSet.add(exerciseSet.value.copyWith(meta: meta.copyWith(duration: duration)));
              widget.onChanged?.call(exerciseSet.value);
            }
          },
        ),
        const Gap(4),
        Wrap(
          spacing: 4,
          children: [
            CSmallFieldContainer(
              title: AppLocale.labelDistance.getTranslation(context),
              text: meta.distance.toString(),
              onTap: () async {
                final distance = await context.push(
                  (context) => CDoubleSelector(
                    data: meta.distance,
                    startInt: 0,
                    validate: (v) {
                      return v <= 0 ? AppLocale.labelSelectValidDistance.getTranslation(context) : '';
                    },
                  ),
                );
                if (distance != null && distance is double) {
                  exerciseSet.add(exerciseSet.value.copyWith(meta: meta.copyWith(distance: distance)));
                  widget.onChanged?.call(exerciseSet.value);
                }
              },
            ),
            CSmallFieldContainer(
              title: '',
              text: meta.unit.getLabelShort(context),
              onTap: () async {
                final distanceUnit = await context.push((context) => CDistanceUnitSelector(data: meta.unit));
                if (distanceUnit != null && distanceUnit is DistanceUnitEnum) {
                  exerciseSet.add(exerciseSet.value.copyWith(meta: meta.copyWith(unit: distanceUnit)));
                  widget.onChanged?.call(exerciseSet.value);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
