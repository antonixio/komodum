import 'package:flutter/src/widgets/framework.dart';

import '../../database_model.dart';
import '../../mappable_model.dart';
import '../../session/exercise_set_meta_training/exercise_set_meta_training_session_model.dart';

abstract class ExerciseSetMetaTrainingTemplateModel with MappableModel, DatabaseModel {
  final int? exerciseSetTrainingTemplateId;
  final int? id;

  ExerciseSetMetaTrainingTemplateModel({
    this.exerciseSetTrainingTemplateId,
    this.id,
  });

  ExerciseSetMetaTrainingTemplateModel copyWithSetId([int? exerciseSetTrainingTemplateId]);

  ExerciseSetMetaTrainingTemplateModel copyWithId([int? id]);

  ExerciseSetMetaTrainingSessionModel toSession();

  String getFormatted(BuildContext context);

  @override
  Map<String, dynamic> toDatabase() => toMap();
}
