import 'package:flutter/material.dart';

import '../../../../../tiggym_shared.dart';
import '../../database_model.dart';
import '../../mappable_model.dart';

abstract class ExerciseSetMetaTrainingSessionModel with MappableModel, DatabaseModel {
  final int? exerciseSetTrainingSessionId;
  final int? id;

  ExerciseSetMetaTrainingSessionModel({
    this.exerciseSetTrainingSessionId,
    this.id,
  });

  ExerciseSetMetaTrainingSessionModel copyWithSetId([int? exerciseSetTrainingSessionId]);

  ExerciseSetMetaTrainingSessionModel copyWithId([int? id]);

  String getFormatted(BuildContext context);

  @override
  Map<String, dynamic> toDatabase() => toMap();

  ExerciseSetMetaTrainingTemplateModel toTemplate();
}
