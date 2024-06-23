import 'package:flutter/material.dart';
import '../../../../../tiggym_shared.dart';
import '../../../../util/extensions/duration_extensions.dart';
import '../../template/exercise_set_meta_training/exercise_set_meta_training_template_model.dart';

import 'exercise_set_meta_training_session_model.dart';

class ExerciseSetMetaTimeTrainingSessionModel extends ExerciseSetMetaTrainingSessionModel {
  final Duration duration;

  ExerciseSetMetaTimeTrainingSessionModel({
    required this.duration,
    super.exerciseSetTrainingSessionId,
    super.id,
  });

  ExerciseSetMetaTimeTrainingSessionModel.dummy() : duration = const Duration(minutes: 10);

  factory ExerciseSetMetaTimeTrainingSessionModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSetMetaTimeTrainingSessionModel(
      duration: Duration(seconds: map['duration']),
      exerciseSetTrainingSessionId: map['exerciseSetTrainingSessionId'],
      id: map['id'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'duration': duration.inSeconds,
      'exerciseSetTrainingSessionId': exerciseSetTrainingSessionId,
      'id': id,
    };
  }

  ExerciseSetMetaTimeTrainingSessionModel copyWith({
    Duration? duration,
    ValueGetter<int?>? exerciseSetTrainingSessionId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseSetMetaTimeTrainingSessionModel(
      duration: duration ?? this.duration,
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
    return duration.hoursMinutesSeconds;
  }

  @override
  ExerciseSetMetaTrainingTemplateModel toTemplate() {
    return ExerciseSetMetaTimeTrainingTemplateModel(duration: duration, exerciseSetTrainingTemplateId: null, id: null);
  }
}
