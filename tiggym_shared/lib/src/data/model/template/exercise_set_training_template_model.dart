import 'package:flutter/material.dart';
import 'package:tiggym_shared/src/data/model/database_model.dart';
import 'exercise_set_meta_training/exercise_set_meta_training_template_model.dart';
import '../mappable_model.dart';

import '../../enum/exercise_type_enum.dart';
import '../session/exercise_set_training_session_model.dart';

class ExerciseSetTrainingTemplateModel with MappableModel, DatabaseModel {
  final int order;
  final ExerciseSetMetaTrainingTemplateModel meta;
  final ExerciseTypeEnum exerciseType;
  final int? exerciseSetGroupTrainingTemplateId;
  final int? id;

  ExerciseSetTrainingTemplateModel({
    required this.meta,
    this.order = 1,
    required this.exerciseType,
    this.exerciseSetGroupTrainingTemplateId,
    this.id,
  });

  factory ExerciseSetTrainingTemplateModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSetTrainingTemplateModel(
      order: map['order'] as int,
      meta: ExerciseTypeEnum.fromName(map['exerciseType']).getTemplateMetaFromMap(map['meta']),
      exerciseType: ExerciseTypeEnum.fromName(map['exerciseType']),
      exerciseSetGroupTrainingTemplateId: map['exerciseSetGroupTrainingTemplateId'] != null ? map['exerciseSetGroupTrainingTemplateId'] as int : null,
      id: map['id'] != null ? map['id'] as int : null,
    );
  }

  ExerciseSetTrainingTemplateModel copyWith({
    int? order,
    ExerciseSetMetaTrainingTemplateModel? meta,
    ExerciseTypeEnum? exerciseType,
    ValueGetter<int?>? exerciseSetGroupTrainingTemplateId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseSetTrainingTemplateModel(
      order: order ?? this.order,
      meta: meta ?? this.meta,
      exerciseType: exerciseType ?? this.exerciseType,
      exerciseSetGroupTrainingTemplateId: exerciseSetGroupTrainingTemplateId != null ? exerciseSetGroupTrainingTemplateId.call() : this.exerciseSetGroupTrainingTemplateId,
      id: id != null ? id.call() : this.id,
    );
  }

  ExerciseSetTrainingTemplateModel duplicate() => copyWith(id: () => null, meta: meta.copyWithId(null).copyWithSetId(null));

  ExerciseSetTrainingSessionModel toSession() {
    return ExerciseSetTrainingSessionModel(
      exerciseType: exerciseType,
      order: order,
      meta: meta.toSession(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'exerciseType': exerciseType.name,
      'order': order,
      'exerciseSetGroupTrainingTemplateId': exerciseSetGroupTrainingTemplateId,
      'id': id,
      'meta': meta.toMap(),
    };
  }

  @override
  Map<String, dynamic> toDatabase() => toMap()..remove('meta');
}
