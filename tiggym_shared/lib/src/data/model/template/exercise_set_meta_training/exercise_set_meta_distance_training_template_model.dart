import 'package:flutter/material.dart';

import '../../../enum/distance_unit_enum.dart';
import '../../session/exercise_set_meta_training/exercise_set_meta_distance_training_session_model.dart';
import '../../session/exercise_set_meta_training/exercise_set_meta_training_session_model.dart';
import 'exercise_set_meta_training_template_model.dart';

class ExerciseSetMetaDistanceTrainingTemplateModel extends ExerciseSetMetaTrainingTemplateModel {
  final double distance;
  final DistanceUnitEnum unit;

  ExerciseSetMetaDistanceTrainingTemplateModel({
    required this.distance,
    required this.unit,
    super.exerciseSetTrainingTemplateId,
    super.id,
  });

  ExerciseSetMetaDistanceTrainingTemplateModel.dummy()
      : distance = 1,
        unit = DistanceUnitEnum.kilometer;

  factory ExerciseSetMetaDistanceTrainingTemplateModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSetMetaDistanceTrainingTemplateModel(
      distance: map['distance'] as double,
      unit: DistanceUnitEnum.fromName(map['unit']),
      exerciseSetTrainingTemplateId: map['exerciseSetTrainingTemplateId'],
      id: map['id'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'distance': distance,
      'unit': unit.name,
      'exerciseSetTrainingTemplateId': exerciseSetTrainingTemplateId,
    };
  }

  ExerciseSetMetaDistanceTrainingTemplateModel copyWith({
    double? distance,
    DistanceUnitEnum? unit,
    ValueGetter<int?>? exerciseSetTrainingTemplateId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseSetMetaDistanceTrainingTemplateModel(
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
    return ExerciseSetMetaDistanceTrainingSessionModel(
      distance: distance,
      unit: unit,
    );
  }

  @override
  String getFormatted(BuildContext context) {
    return "${distance.toStringAsFixed(1)} ${unit.getLabelShort(context)}";
  }
}
