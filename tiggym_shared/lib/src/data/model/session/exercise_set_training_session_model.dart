import 'package:flutter/material.dart';
import 'package:tiggym_shared/src/data/model/database_model.dart';
import 'package:tiggym_shared/src/util/all.dart';
import 'package:uuid/uuid.dart';
import '../../../../tiggym_shared.dart';
import '../mappable_model.dart';
import 'exercise_set_meta_training/exercise_set_meta_training_session_model.dart';

import '../../enum/exercise_type_enum.dart';

class ExerciseSetTrainingSessionModel with MappableModel, DatabaseModel {
  final int order;
  final ExerciseSetMetaTrainingSessionModel meta;
  final ExerciseTypeEnum exerciseType;
  final int? exerciseSetGroupTrainingSessionId;
  final int? id;
  final String? syncId;
  final bool done;

  ExerciseSetTrainingSessionModel({
    required this.meta,
    this.order = 1,
    required this.exerciseType,
    this.exerciseSetGroupTrainingSessionId,
    this.id,
    this.done = false,
    String? syncId,
  }) : syncId = syncId ?? UuidService.instance.uuid();

  factory ExerciseSetTrainingSessionModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSetTrainingSessionModel(
      order: map['order'] as int,
      meta: ExerciseTypeEnum.fromName(map['exerciseType']).getSessionMetaFromMap(map['meta']),
      done: map['done'] == 1,
      exerciseType: ExerciseTypeEnum.fromName(map['exerciseType']),
      exerciseSetGroupTrainingSessionId: map['exerciseSetGroupTrainingSessionId'] != null ? map['exerciseSetGroupTrainingSessionId'] as int : null,
      id: map['id'] != null ? map['id'] as int : null,
      syncId: map['syncId'] != null ? map['syncId'] as String : null,
    );
  }

  ExerciseSetTrainingSessionModel copyWith({
    int? order,
    ExerciseSetMetaTrainingSessionModel? meta,
    ExerciseTypeEnum? exerciseType,
    ValueGetter<int?>? exerciseSetGroupTrainingSessionId,
    ValueGetter<int?>? id,
    ValueGetter<String?>? syncId,
    bool? done,
  }) {
    return ExerciseSetTrainingSessionModel(
      order: order ?? this.order,
      meta: meta ?? this.meta,
      done: done ?? this.done,
      exerciseType: exerciseType ?? this.exerciseType,
      exerciseSetGroupTrainingSessionId: exerciseSetGroupTrainingSessionId != null ? exerciseSetGroupTrainingSessionId.call() : this.exerciseSetGroupTrainingSessionId,
      id: id != null ? id.call() : this.id,
      syncId: syncId != null ? syncId.call() : this.syncId,
    );
  }

  ExerciseSetTrainingSessionModel duplicate() => copyWith(
        id: () => null,
        meta: meta.copyWithId(null).copyWithSetId(null),
        syncId: () => UuidService.instance.uuid(),
        done: false,
      );

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'exerciseType': exerciseType.name,
      'order': order,
      'exerciseSetGroupTrainingSessionId': exerciseSetGroupTrainingSessionId,
      'id': id,
      'done': done ? 1 : 0,
      'meta': meta.toMap(),
      'syncId': syncId,
    };
  }

  @override
  Map<String, dynamic> toDatabase() {
    return toMap()
      ..remove('meta')
      ..remove('syncId');
  }

  ExerciseSetTrainingTemplateModel toTemplate() {
    return ExerciseSetTrainingTemplateModel(
      exerciseType: exerciseType,
      order: order,
      meta: meta.toTemplate(),
    );
  }
}
