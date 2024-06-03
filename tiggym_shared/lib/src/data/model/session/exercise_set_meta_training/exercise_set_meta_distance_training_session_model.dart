import 'package:flutter/material.dart';

import '../../../enum/distance_unit_enum.dart';
import 'exercise_set_meta_training_session_model.dart';

class ExerciseSetMetaDistanceTrainingSessionModel extends ExerciseSetMetaTrainingSessionModel {
  final double distance;
  final DistanceUnitEnum unit;

  ExerciseSetMetaDistanceTrainingSessionModel({
    required this.distance,
    required this.unit,
    super.exerciseSetTrainingSessionId,
    super.id,
  });

  ExerciseSetMetaDistanceTrainingSessionModel.dummy()
      : distance = 1,
        unit = DistanceUnitEnum.kilometer;

  factory ExerciseSetMetaDistanceTrainingSessionModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSetMetaDistanceTrainingSessionModel(
      distance: map['distance'] as double,
      unit: DistanceUnitEnum.fromName(map['unit']),
      exerciseSetTrainingSessionId: map['exerciseSetTrainingSessionId'],
      id: map['id'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'distance': distance,
      'unit': unit.name,
      'exerciseSetTrainingSessionId': exerciseSetTrainingSessionId,
    };
  }

  ExerciseSetMetaDistanceTrainingSessionModel copyWith({
    double? distance,
    DistanceUnitEnum? unit,
    ValueGetter<int?>? exerciseSetTrainingSessionId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseSetMetaDistanceTrainingSessionModel(
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
    return "${distance.toStringAsFixed(1)} ${unit.getLabelShort(context)}";
  }
}
