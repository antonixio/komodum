import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tiggym_shared/src/util/all.dart';
import '../../../util/extensions/map_extensions.dart';
import '../../enum/exercise_group_type_enum.dart';
import '../database_model.dart';
import '../exercise/exercise_model.dart';
import '../mappable_model.dart';
import '../orderable_model.dart';

import 'exercise_set_group_training_session_model.dart';
import 'exercise_training_session_model.dart';

class ExerciseGroupTrainingSessionModel with MappableModel, DatabaseModel, OrderableModel<ExerciseGroupTrainingSessionModel> {
  final ExerciseGroupTypeEnum groupType;
  final List<ExerciseTrainingSessionModel> exercises;
  @override
  final int order;
  final int? trainingSessionId;
  final int? id;
  final String? syncId;

  ExerciseGroupTrainingSessionModel({
    required this.groupType,
    required this.exercises,
    this.order = 1,
    this.trainingSessionId,
    this.id,
    String? syncId,
  }) : syncId = syncId ?? UuidService.instance.uuid();

  ExerciseGroupTrainingSessionModel.unique({
    required ExerciseTrainingSessionModel exercise,
    this.order = 1,
    this.id,
    this.trainingSessionId,
  })  : groupType = ExerciseGroupTypeEnum.unique,
        exercises = [exercise],
        syncId = UuidService.instance.uuid();

  ExerciseGroupTrainingSessionModel.uniqueFromExercise({
    required ExerciseModel exercise,
    this.order = 1,
    this.id,
    this.trainingSessionId,
  })  : groupType = ExerciseGroupTypeEnum.unique,
        syncId = UuidService.instance.uuid(),
        exercises = [
          ExerciseTrainingSessionModel(
            exercise: exercise,
            order: 1,
            groupSets: [
              ExerciseSetGroupTrainingSessionModel.uniqueFromExercise(
                exercise: exercise,
              ),
            ],
          ),
        ];

  ExerciseGroupTrainingSessionModel.compoundFromExercise({
    required ExerciseModel exercise,
    this.order = 1,
    this.trainingSessionId,
    this.id,
  })  : groupType = ExerciseGroupTypeEnum.compound,
        syncId = UuidService.instance.uuid(),
        exercises = [
          ExerciseTrainingSessionModel(
            exercise: exercise,
            order: 1,
            groupSets: [
              ExerciseSetGroupTrainingSessionModel.multipleFromExercise(
                exercise: exercise,
                quantity: 1,
              ),
            ],
          ),
        ];

  factory ExerciseGroupTrainingSessionModel.fromMap(Map<String, dynamic> map) {
    return ExerciseGroupTrainingSessionModel(
      groupType: ExerciseGroupTypeEnum.fromName(map['groupType']),
      order: map['order'] as int,
      trainingSessionId: map['trainingSessionId'] != null ? map['trainingSessionId'] as int : null,
      id: map['id'] != null ? map['id'] as int : null,
      exercises: (map['exercises'] as List<dynamic>).map((e) => ExerciseTrainingSessionModel.fromMap(e)).toList(),
      syncId: map['syncId'] != null ? map['syncId'] as String : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'groupType': groupType.name,
      'order': order,
      'trainingSessionId': trainingSessionId,
      'id': id,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'syncId': syncId,
    };
  }

  @override
  Map<String, dynamic> toDatabase() => toMap()
    ..remove('exercises')
    ..remove('syncId');

  ExerciseGroupTrainingSessionModel copyWith({
    ExerciseGroupTypeEnum? groupType,
    List<ExerciseTrainingSessionModel>? exercises,
    int? order,
    ValueGetter<int?>? trainingSessionId,
    ValueGetter<int?>? id,
    ValueGetter<String?>? syncId,
  }) {
    return ExerciseGroupTrainingSessionModel(
      groupType: groupType ?? this.groupType,
      exercises: exercises ?? this.exercises,
      order: order ?? this.order,
      trainingSessionId: trainingSessionId != null ? trainingSessionId.call() : this.trainingSessionId,
      id: id != null ? id.call() : this.id,
      syncId: syncId != null ? syncId.call() : this.syncId,
    );
  }

  ExerciseGroupTrainingSessionModel changeAndValidate({
    required List<ExerciseTrainingSessionModel> exercises,
  }) {
    final copy = exercises.toList()..sort((a, b) => a.order.compareTo(b.order));
    return copyWith(
      exercises: List.generate(copy.length, (index) => copy[index].copyWith(order: index + 1)),
      syncId: () => syncId,
    );
  }

  ExerciseGroupTrainingSessionModel addSimpleSet() {
    return copyWith(
      exercises: exercises.map((e) => e.addSimpleSet()).toList(),
    );
  }

  ExerciseGroupTrainingSessionModel addMultipleSet({int quantity = 3}) {
    return copyWith(
      exercises: exercises.map((e) => e.addMultipleSet(quantity: quantity)).toList(),
    );
  }

  ExerciseGroupTrainingSessionModel addExercise(ExerciseModel exercise) {
    return copyWith(exercises: [
      ...exercises,
      ExerciseTrainingSessionModel(
          exercise: exercise,
          order: exercises.fold(0, (previousValue, element) => max(previousValue, element.order)) + 1,
          groupSets: List.generate(
            max(exercises.firstOrNull?.groupSets.length ?? 0, 1),
            (index) => ExerciseSetGroupTrainingSessionModel.multipleFromExercise(
              exercise: exercise,
              quantity: index + 1,
            ),
          )),
    ]);
  }

  ExerciseGroupTrainingSessionModel removeExercise(ExerciseTrainingSessionModel exercise) {
    final remaining = ([...exercises]
      ..remove(exercise)
      ..sort((a, b) => a.order.compareTo(b.order)));
    final newExercises = List.generate(remaining.length, (index) => remaining.elementAt(index).copyWith(order: index + 1));

    return changeAndValidate(exercises: newExercises);
  }

  @override
  ExerciseGroupTrainingSessionModel copyWithOrder(int order) => copyWith(order: order);
}
