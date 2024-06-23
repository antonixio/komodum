import 'package:flutter/material.dart';
import '../../../../../tiggym_shared.dart';
import '../../../../util/extensions/duration_extensions.dart';

import '../../../enum/distance_unit_enum.dart';
import 'exercise_set_meta_training_session_model.dart';

class ExerciseSetMetaTimeAndDistanceTrainingSessionModel extends ExerciseSetMetaTrainingSessionModel {
  final Duration duration;
  final double distance;
  final DistanceUnitEnum unit;

  ExerciseSetMetaTimeAndDistanceTrainingSessionModel({
    required this.duration,
    required this.distance,
    required this.unit,
    super.exerciseSetTrainingSessionId,
    super.id,
  });

  ExerciseSetMetaTimeAndDistanceTrainingSessionModel.dummy()
      : duration = const Duration(minutes: 10),
        distance = 1,
        unit = DistanceUnitEnum.kilometer;

  factory ExerciseSetMetaTimeAndDistanceTrainingSessionModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSetMetaTimeAndDistanceTrainingSessionModel(
      duration: Duration(seconds: map['duration']),
      distance: map['distance'] as double,
      unit: DistanceUnitEnum.fromName(map['unit']),
      exerciseSetTrainingSessionId: map['exerciseSetTrainingSessionId'],
      id: map['id'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'duration': duration.inSeconds,
      'distance': distance,
      'unit': unit.name,
      'exerciseSetTrainingSessionId': exerciseSetTrainingSessionId,
      'id': id,
    };
  }

  ExerciseSetMetaTimeAndDistanceTrainingSessionModel copyWith({
    Duration? duration,
    double? distance,
    DistanceUnitEnum? unit,
    ValueGetter<int?>? exerciseSetTrainingSessionId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseSetMetaTimeAndDistanceTrainingSessionModel(
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      unit: unit ?? this.unit,
      exerciseSetTrainingSessionId: exerciseSetTrainingSessionId != null ? exerciseSetTrainingSessionId.call() : this.exerciseSetTrainingSessionId,
      id: id != null ? id.call() : this.id,
    );
  }

  @override
  ExerciseSetMetaTrainingSessionModel copyWithSetId([int? exerciseSetTrainingSessionId]) {
    return copyWith(exerciseSetTrainingSessionId: () => exerciseSetTrainingSessionId);
  }

  @override
  ExerciseSetMetaTrainingSessionModel copyWithId([int? id]) {
    return copyWith(id: () => id);
  }

  @override
  String getFormatted(BuildContext context) {
    return "${duration.hoursMinutesSeconds} - ${distance.toStringAsFixed(1)}${unit.getLabelShort(context)}";
  }

  @override
  ExerciseSetMetaTrainingTemplateModel toTemplate() {
    return ExerciseSetMetaTimeAndDistanceTrainingTemplateModel(
      distance: distance,
      unit: unit,
      duration: duration,
    );
  }
}
