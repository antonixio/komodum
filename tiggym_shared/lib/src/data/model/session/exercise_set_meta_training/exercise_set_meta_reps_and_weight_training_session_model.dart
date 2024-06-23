import 'package:flutter/material.dart';

import '../../../../../tiggym_shared.dart';
import '../../../../util/extensions/string_extensions.dart';
import '../../../enum/weight_unit_enum.dart';
import '../../../localization/app_locale.dart';
import 'exercise_set_meta_training_session_model.dart';

class ExerciseSetMetaRepsAndWeightTrainingSessionModel extends ExerciseSetMetaTrainingSessionModel {
  final int reps;
  final double weight;
  final WeightUnitEnum weightUnit;

  ExerciseSetMetaRepsAndWeightTrainingSessionModel({
    required this.reps,
    required this.weight,
    required this.weightUnit,
    super.exerciseSetTrainingSessionId,
    super.id,
  });

  ExerciseSetMetaRepsAndWeightTrainingSessionModel.dummy()
      : reps = 10,
        weight = 10,
        weightUnit = WeightUnitEnum.kilogram;

  factory ExerciseSetMetaRepsAndWeightTrainingSessionModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSetMetaRepsAndWeightTrainingSessionModel(
      reps: map['reps'] as int,
      weight: map['weight'] as double,
      weightUnit: WeightUnitEnum.fromName(map['weightUnit']),
      exerciseSetTrainingSessionId: map['exerciseSetTrainingSessionId'],
      id: map['id'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reps': reps,
      'weight': weight,
      'weightUnit': weightUnit.name,
      'exerciseSetTrainingSessionId': exerciseSetTrainingSessionId,
      'id': id,
    };
  }

  ExerciseSetMetaRepsAndWeightTrainingSessionModel copyWith({
    int? reps,
    double? weight,
    WeightUnitEnum? weightUnit,
    ValueGetter<int?>? exerciseSetTrainingSessionId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseSetMetaRepsAndWeightTrainingSessionModel(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
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
    return "$reps x ${weight.toStringAsFixed(1)} ${weightUnit.getLabel(context)}";
  }

  @override
  ExerciseSetMetaTrainingTemplateModel toTemplate() {
    return ExerciseSetMetaRepsAndWeightTrainingTemplateModel(
      reps: reps,
      weight: weight,
      weightUnit: weightUnit,
    );
  }
}
