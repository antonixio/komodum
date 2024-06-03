import 'package:flutter/material.dart';
import '../../../../util/extensions/string_extensions.dart';
import '../../../localization/app_locale.dart';

import '../../session/exercise_set_meta_training/exercise_set_meta_reps_training_session_model.dart';
import '../../session/exercise_set_meta_training/exercise_set_meta_training_session_model.dart';
import 'exercise_set_meta_training_template_model.dart';

class ExerciseSetMetaRepsTrainingTemplateModel extends ExerciseSetMetaTrainingTemplateModel {
  final int reps;

  ExerciseSetMetaRepsTrainingTemplateModel({
    required this.reps,
    super.exerciseSetTrainingTemplateId,
    super.id,
  });

  ExerciseSetMetaRepsTrainingTemplateModel.dummy() : reps = 10;

  factory ExerciseSetMetaRepsTrainingTemplateModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSetMetaRepsTrainingTemplateModel(
      reps: map['reps'] as int,
      exerciseSetTrainingTemplateId: map['exerciseSetTrainingTemplateId'],
      id: map['id'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reps': reps,
      'exerciseSetTrainingTemplateId': exerciseSetTrainingTemplateId,
      'id': id,
    };
  }

  ExerciseSetMetaRepsTrainingTemplateModel copyWith({
    int? reps,
    ValueGetter<int?>? exerciseSetTrainingTemplateId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseSetMetaRepsTrainingTemplateModel(
      reps: reps ?? this.reps,
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
    return ExerciseSetMetaRepsTrainingSessionModel(
      reps: reps,
    );
  }

  @override
  String getFormatted(BuildContext context) {
    return "$reps ${AppLocale.labelReps.getTranslation(context)}";
  }
}
