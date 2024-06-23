import 'package:flutter/material.dart';
import '../../../../../tiggym_shared.dart';
import '../../../../util/extensions/string_extensions.dart';

import '../../../localization/app_locale.dart';
import 'exercise_set_meta_training_session_model.dart';

class ExerciseSetMetaRepsTrainingSessionModel extends ExerciseSetMetaTrainingSessionModel {
  final int reps;

  ExerciseSetMetaRepsTrainingSessionModel({
    required this.reps,
    super.exerciseSetTrainingSessionId,
    super.id,
  });

  ExerciseSetMetaRepsTrainingSessionModel.dummy() : reps = 10;

  factory ExerciseSetMetaRepsTrainingSessionModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSetMetaRepsTrainingSessionModel(
      reps: map['reps'] as int,
      exerciseSetTrainingSessionId: map['exerciseSetTrainingSessionId'],
      id: map['id'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reps': reps,
      'exerciseSetTrainingSessionId': exerciseSetTrainingSessionId,
      'id': id,
    };
  }

  ExerciseSetMetaRepsTrainingSessionModel copyWith({
    int? reps,
    ValueGetter<int?>? exerciseSetTrainingSessionId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseSetMetaRepsTrainingSessionModel(
      reps: reps ?? this.reps,
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
  ExerciseSetMetaTrainingTemplateModel toTemplate() {
    return ExerciseSetMetaRepsTrainingTemplateModel(
      reps: reps,
    );
  }

  @override
  String getFormatted(BuildContext context) {
    return "$reps";
  }
}
