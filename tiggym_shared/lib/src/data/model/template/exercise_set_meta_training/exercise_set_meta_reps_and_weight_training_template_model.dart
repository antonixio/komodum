import 'package:flutter/material.dart';
import '../../../../util/extensions/string_extensions.dart';
import '../../../../util/extensions/string_extensions.dart';

import '../../../enum/weight_unit_enum.dart';
import '../../../localization/app_locale.dart';
import '../../session/exercise_set_meta_training/exercise_set_meta_reps_and_weight_training_session_model.dart';
import '../../session/exercise_set_meta_training/exercise_set_meta_training_session_model.dart';
import 'exercise_set_meta_training_template_model.dart';

class ExerciseSetMetaRepsAndWeightTrainingTemplateModel extends ExerciseSetMetaTrainingTemplateModel {
  final int reps;
  final double weight;
  final WeightUnitEnum weightUnit;

  ExerciseSetMetaRepsAndWeightTrainingTemplateModel({
    required this.reps,
    required this.weight,
    required this.weightUnit,
    super.exerciseSetTrainingTemplateId,
    super.id,
  });

  ExerciseSetMetaRepsAndWeightTrainingTemplateModel.dummy()
      : reps = 10,
        weight = 10,
        weightUnit = WeightUnitEnum.kilogram;

  factory ExerciseSetMetaRepsAndWeightTrainingTemplateModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSetMetaRepsAndWeightTrainingTemplateModel(
      reps: map['reps'] as int,
      weight: map['weight'] as double,
      weightUnit: WeightUnitEnum.fromName(map['weightUnit']),
      exerciseSetTrainingTemplateId: map['exerciseSetTrainingTemplateId'],
      id: map['id'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reps': reps,
      'weight': weight,
      'weightUnit': weightUnit.name,
      'exerciseSetTrainingTemplateId': exerciseSetTrainingTemplateId,
      'id': id,
    };
  }

  ExerciseSetMetaRepsAndWeightTrainingTemplateModel copyWith({
    int? reps,
    double? weight,
    WeightUnitEnum? weightUnit,
    ValueGetter<int?>? exerciseSetTrainingTemplateId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseSetMetaRepsAndWeightTrainingTemplateModel(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
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
    return ExerciseSetMetaRepsAndWeightTrainingSessionModel(
      reps: reps,
      weight: weight,
      weightUnit: weightUnit,
    );
  }

  @override
  String getFormatted(BuildContext context) {
    return "$reps ${AppLocale.labelReps.getTranslation(context)} x ${weight.toStringAsFixed(1)} ${weightUnit.getLabel(context)}";
  }
}
