import 'package:flutter/material.dart';
import '../../../../util/extensions/duration_extensions.dart';

import '../../../enum/distance_unit_enum.dart';
import '../../session/exercise_set_meta_training/exercise_set_meta_time_and_distance_training_session_model.dart';
import '../../session/exercise_set_meta_training/exercise_set_meta_training_session_model.dart';
import 'exercise_set_meta_training_template_model.dart';

class ExerciseSetMetaTimeAndDistanceTrainingTemplateModel extends ExerciseSetMetaTrainingTemplateModel {
  final Duration duration;
  final double distance;
  final DistanceUnitEnum unit;

  ExerciseSetMetaTimeAndDistanceTrainingTemplateModel({
    required this.duration,
    required this.distance,
    required this.unit,
    super.exerciseSetTrainingTemplateId,
    super.id,
  });

  ExerciseSetMetaTimeAndDistanceTrainingTemplateModel.dummy()
      : duration = const Duration(minutes: 10),
        distance = 1,
        unit = DistanceUnitEnum.kilometer;

  factory ExerciseSetMetaTimeAndDistanceTrainingTemplateModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSetMetaTimeAndDistanceTrainingTemplateModel(
      duration: Duration(seconds: map['duration']),
      distance: map['distance'] as double,
      unit: DistanceUnitEnum.fromName(map['unit']),
      exerciseSetTrainingTemplateId: map['exerciseSetTrainingTemplateId'],
      id: map['id'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'duration': duration.inSeconds,
      'distance': distance,
      'unit': unit.name,
      'exerciseSetTrainingTemplateId': exerciseSetTrainingTemplateId,
      'id': id,
    };
  }

  ExerciseSetMetaTimeAndDistanceTrainingTemplateModel copyWith({
    Duration? duration,
    double? distance,
    DistanceUnitEnum? unit,
    ValueGetter<int?>? exerciseSetTrainingTemplateId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseSetMetaTimeAndDistanceTrainingTemplateModel(
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      unit: unit ?? this.unit,
      exerciseSetTrainingTemplateId: exerciseSetTrainingTemplateId != null ? exerciseSetTrainingTemplateId.call() : this.exerciseSetTrainingTemplateId,
      id: id != null ? id.call() : this.id,
    );
  }

  @override
  ExerciseSetMetaTrainingTemplateModel copyWithSetId([int? exerciseSetTrainingTemplateId]) {
    return copyWith(exerciseSetTrainingTemplateId: () => exerciseSetTrainingTemplateId);
  }

  @override
  ExerciseSetMetaTrainingTemplateModel copyWithId([int? id]) {
    return copyWith(id: () => id);
  }

  @override
  ExerciseSetMetaTrainingSessionModel toSession() {
    return ExerciseSetMetaTimeAndDistanceTrainingSessionModel(
      distance: distance,
      unit: unit,
      duration: duration,
    );
  }

  @override
  String getFormatted(BuildContext context) {
    return "${duration.hoursMinutesSeconds} - ${distance.toStringAsFixed(1)}${unit.getLabelShort(context)}";
  }
}
