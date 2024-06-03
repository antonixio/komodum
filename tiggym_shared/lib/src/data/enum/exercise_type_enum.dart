import 'package:flutter/material.dart';
import '../../util/extensions/string_extensions.dart';

import '../../util/extensions/string_extensions.dart';
import '../model/session/exercise_set_meta_training/exercise_set_meta_distance_training_session_model.dart';
import '../model/session/exercise_set_meta_training/exercise_set_meta_reps_and_weight_training_session_model.dart';
import '../model/session/exercise_set_meta_training/exercise_set_meta_reps_training_session_model.dart';
import '../model/session/exercise_set_meta_training/exercise_set_meta_time_and_distance_training_session_model.dart';
import '../model/session/exercise_set_meta_training/exercise_set_meta_time_training_session_model.dart';
import '../model/session/exercise_set_meta_training/exercise_set_meta_training_session_model.dart';
import '../model/template/exercise_set_meta_training/exercise_set_meta_distance_training_template_model.dart';
import '../model/template/exercise_set_meta_training/exercise_set_meta_reps_and_weight_training_template_model.dart';
import '../model/template/exercise_set_meta_training/exercise_set_meta_reps_training_template_model.dart';
import '../model/template/exercise_set_meta_training/exercise_set_meta_time_and_distance_training_template_model.dart';
import '../model/template/exercise_set_meta_training/exercise_set_meta_time_training_template_model.dart';
import '../model/template/exercise_set_meta_training/exercise_set_meta_training_template_model.dart';

enum ExerciseTypeEnum {
  repsAndWeight,
  reps,
  time,
  distance,
  timeAndDistance;

  String getLabel(BuildContext context) => 'label${name.capitalize()}'.getTranslation(context);

  ExerciseSetMetaTrainingTemplateModel getDummyExerciseSetTrainingMetaTemplate() {
    switch (this) {
      case ExerciseTypeEnum.reps:
        return ExerciseSetMetaRepsTrainingTemplateModel.dummy();
      case ExerciseTypeEnum.repsAndWeight:
        return ExerciseSetMetaRepsAndWeightTrainingTemplateModel.dummy();
      case ExerciseTypeEnum.time:
        return ExerciseSetMetaTimeTrainingTemplateModel.dummy();
      case ExerciseTypeEnum.distance:
        return ExerciseSetMetaDistanceTrainingTemplateModel.dummy();
      case ExerciseTypeEnum.timeAndDistance:
        return ExerciseSetMetaTimeAndDistanceTrainingTemplateModel.dummy();
    }
  }

  ExerciseSetMetaTrainingSessionModel getDummyExerciseSetTrainingMetaSession() {
    switch (this) {
      case ExerciseTypeEnum.reps:
        return ExerciseSetMetaRepsTrainingSessionModel.dummy();
      case ExerciseTypeEnum.repsAndWeight:
        return ExerciseSetMetaRepsAndWeightTrainingSessionModel.dummy();
      case ExerciseTypeEnum.time:
        return ExerciseSetMetaTimeTrainingSessionModel.dummy();
      case ExerciseTypeEnum.distance:
        return ExerciseSetMetaDistanceTrainingSessionModel.dummy();
      case ExerciseTypeEnum.timeAndDistance:
        return ExerciseSetMetaTimeAndDistanceTrainingSessionModel.dummy();
    }
  }

  ExerciseSetMetaTrainingSessionModel getSessionMetaFromMap(Map<String, dynamic> map) {
    switch (this) {
      case ExerciseTypeEnum.reps:
        return ExerciseSetMetaRepsTrainingSessionModel.fromMap(map);
      case ExerciseTypeEnum.repsAndWeight:
        return ExerciseSetMetaRepsAndWeightTrainingSessionModel.fromMap(map);
      case ExerciseTypeEnum.time:
        return ExerciseSetMetaTimeTrainingSessionModel.fromMap(map);
      case ExerciseTypeEnum.distance:
        return ExerciseSetMetaDistanceTrainingSessionModel.fromMap(map);
      case ExerciseTypeEnum.timeAndDistance:
        return ExerciseSetMetaTimeAndDistanceTrainingSessionModel.fromMap(map);
    }
  }

  ExerciseSetMetaTrainingTemplateModel getTemplateMetaFromMap(Map<String, dynamic> map) {
    switch (this) {
      case ExerciseTypeEnum.reps:
        return ExerciseSetMetaRepsTrainingTemplateModel.fromMap(map);
      case ExerciseTypeEnum.repsAndWeight:
        return ExerciseSetMetaRepsAndWeightTrainingTemplateModel.fromMap(map);
      case ExerciseTypeEnum.time:
        return ExerciseSetMetaTimeTrainingTemplateModel.fromMap(map);
      case ExerciseTypeEnum.distance:
        return ExerciseSetMetaDistanceTrainingTemplateModel.fromMap(map);
      case ExerciseTypeEnum.timeAndDistance:
        return ExerciseSetMetaTimeAndDistanceTrainingTemplateModel.fromMap(map);
    }
  }

  static ExerciseTypeEnum fromName(String name) => ExerciseTypeEnum.values.firstWhere((element) => element.name == name);
}
