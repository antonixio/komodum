import 'package:flutter/material.dart';

import '../../../../util/extensions/duration_extensions.dart';
import '../../session/exercise_set_meta_training/exercise_set_meta_time_training_session_model.dart';
import '../../session/exercise_set_meta_training/exercise_set_meta_training_session_model.dart';
import 'exercise_set_meta_training_template_model.dart';

class ExerciseSetMetaTimeTrainingTemplateModel extends ExerciseSetMetaTrainingTemplateModel {
  final Duration duration;

  ExerciseSetMetaTimeTrainingTemplateModel({
    required this.duration,
    super.exerciseSetTrainingTemplateId,
    super.id,
  });

  ExerciseSetMetaTimeTrainingTemplateModel.dummy() : duration = const Duration(minutes: 10);

  factory ExerciseSetMetaTimeTrainingTemplateModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSetMetaTimeTrainingTemplateModel(
      duration: Duration(seconds: map['duration']),
      exerciseSetTrainingTemplateId: map['exerciseSetTrainingTemplateId'],
      id: map['id'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'duration': duration.inSeconds,
      'exerciseSetTrainingTemplateId': exerciseSetTrainingTemplateId,
      'id': id,
    };
  }

  ExerciseSetMetaTimeTrainingTemplateModel copyWith({
    Duration? duration,
    ValueGetter<int?>? exerciseSetTrainingTemplateId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseSetMetaTimeTrainingTemplateModel(
      duration: duration ?? this.duration,
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
    return ExerciseSetMetaTimeTrainingSessionModel(duration: duration, exerciseSetTrainingSessionId: null, id: null);
  }

  @override
  String getFormatted(BuildContext context) {
    return duration.hoursMinutesSeconds;
  }
}
