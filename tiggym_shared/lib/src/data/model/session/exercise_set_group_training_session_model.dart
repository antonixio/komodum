import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tiggym_shared/src/data/model/database_model.dart';

import '../../../util/extensions/iterable_extensions.dart';
import '../../enum/exercise_set_group_type_enum.dart';
import '../exercise/exercise_model.dart';
import '../mappable_model.dart';
import '../orderable_model.dart';
import 'exercise_set_training_session_model.dart';

class ExerciseSetGroupTrainingSessionModel with MappableModel, DatabaseModel, OrderableModel<ExerciseSetGroupTrainingSessionModel> {
  final ExerciseSetGroupTypeEnum groupType;
  final List<ExerciseSetTrainingSessionModel> sets;
  @override
  final int order;
  final int? exerciseTrainingSessionId;
  final int? id;

  ExerciseSetGroupTrainingSessionModel({
    required this.groupType,
    required this.sets,
    required this.order,
    this.exerciseTrainingSessionId,
    this.id,
  });

  ExerciseSetGroupTrainingSessionModel.uniqueFromExercise({
    required ExerciseModel exercise,
    this.order = 1,
    this.exerciseTrainingSessionId,
    this.id,
  })  : groupType = ExerciseSetGroupTypeEnum.unique,
        sets = [
          ExerciseSetTrainingSessionModel(
            meta: exercise.type.getDummyExerciseSetTrainingMetaSession(),
            exerciseType: exercise.type,
            order: 1,
          ),
        ];

  ExerciseSetGroupTrainingSessionModel.multipleFromExercise({
    required ExerciseModel exercise,
    this.order = 1,
    int quantity = 3,
    this.exerciseTrainingSessionId,
    this.id,
  })  : groupType = ExerciseSetGroupTypeEnum.multiple,
        sets = List.generate(
            quantity,
            (index) => ExerciseSetTrainingSessionModel(
                  meta: exercise.type.getDummyExerciseSetTrainingMetaSession(),
                  exerciseType: exercise.type,
                  order: index + 1,
                ));

  factory ExerciseSetGroupTrainingSessionModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSetGroupTrainingSessionModel(
      groupType: ExerciseSetGroupTypeEnum.fromName(map['groupType']),
      sets: (map['sets'] as List<dynamic>).map((e) => ExerciseSetTrainingSessionModel.fromMap(e)).toList(),
      order: map['order'] as int,
      exerciseTrainingSessionId: map['exerciseTrainingSessionId'] != null ? map['exerciseTrainingSessionId'] as int : null,
      id: map['id'] != null ? map['id'] as int : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'groupType': groupType.name,
      'order': order,
      'exerciseTrainingSessionId': exerciseTrainingSessionId,
      'id': id,
      'sets': sets.map((e) => e.toMap()).toList(),
    };
  }

  @override
  Map<String, dynamic> toDatabase() => toMap()..remove('sets');

  ExerciseSetGroupTrainingSessionModel copyWith({
    ExerciseSetGroupTypeEnum? groupType,
    List<ExerciseSetTrainingSessionModel>? sets,
    int? order,
    ValueGetter<int?>? exerciseTrainingSessionId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseSetGroupTrainingSessionModel(
      groupType: groupType ?? this.groupType,
      sets: sets ?? this.sets,
      order: order ?? this.order,
      exerciseTrainingSessionId: exerciseTrainingSessionId != null ? exerciseTrainingSessionId.call() : this.exerciseTrainingSessionId,
      id: id != null ? id.call() : this.id,
    );
  }

  ExerciseSetGroupTrainingSessionModel duplicate() {
    return copyWith(
      id: () => null,
      sets: sets.map((e) => e.duplicate()).toList(),
    );
  }

  ExerciseSetGroupTrainingSessionModel changeAndValidate({
    required List<ExerciseSetTrainingSessionModel> sets,
  }) {
    final copy = [...sets]..sort((a, b) => a.order.compareTo(b.order));
    return copyWith(
      sets: List.generate(copy.length, (index) => copy[index].copyWith(order: index + 1)),
    );
  }

  ExerciseSetGroupTrainingSessionModel removeSet(ExerciseSetTrainingSessionModel exerciseSet) {
    final remaining = ([...sets]
      ..removeWhere((e) => e.syncId == exerciseSet.syncId)
      ..sort((a, b) => a.order.compareTo(b.order)));
    final newSets = List.generate(remaining.length, (index) => remaining.elementAt(index).copyWith(order: index + 1));

    return changeAndValidate(sets: newSets);
  }

  ExerciseSetGroupTrainingSessionModel updateSet(ExerciseSetTrainingSessionModel current, ExerciseSetTrainingSessionModel newSet) {
    return changeAndValidate(sets: sets.replaceFirstWhere((c) => c.syncId == current.syncId, newSet).toList());
  }

  ExerciseSetGroupTrainingSessionModel addInnerSet() {
    return copyWith(sets: [
      ...sets,
      (sets.lastOrNull ??
              ExerciseSetTrainingSessionModel(
                meta: sets.last.exerciseType.getDummyExerciseSetTrainingMetaSession(),
                exerciseType: sets.last.exerciseType,
              ))
          .copyWith(id: () => null, order: sets.fold(0, (previousValue, element) => max(previousValue, element.order)) + 1, syncId: () => null, done: false),
    ]);
  }

  @override
  ExerciseSetGroupTrainingSessionModel copyWithOrder(int order) => copyWith(order: order);
}
