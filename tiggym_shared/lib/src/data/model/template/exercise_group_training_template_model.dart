import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tiggym_shared/src/data/model/database_model.dart';
import '../orderable_model.dart';

import '../../enum/exercise_group_type_enum.dart';
import '../exercise/exercise_model.dart';
import '../mappable_model.dart';
import '../session/exercise_group_training_session_model.dart';
import 'exercise_set_group_training_template_model.dart';
import 'exercise_training_template_model.dart';

class ExerciseGroupTrainingTemplateModel with MappableModel, DatabaseModel, OrderableModel<ExerciseGroupTrainingTemplateModel> {
  final ExerciseGroupTypeEnum groupType;
  final List<ExerciseTrainingTemplateModel> exercises;
  @override
  final int order;
  final int? trainingTemplateId;
  final int? id;

  ExerciseGroupTrainingTemplateModel({
    required this.groupType,
    required this.exercises,
    this.order = 1,
    this.trainingTemplateId,
    this.id,
  });

  ExerciseGroupTrainingTemplateModel.unique({
    required ExerciseTrainingTemplateModel exercise,
    this.order = 1,
    this.id,
    this.trainingTemplateId,
  })  : groupType = ExerciseGroupTypeEnum.unique,
        exercises = [exercise];

  ExerciseGroupTrainingTemplateModel.uniqueFromExercise({
    required ExerciseModel exercise,
    this.order = 1,
    this.id,
    this.trainingTemplateId,
  })  : groupType = ExerciseGroupTypeEnum.unique,
        exercises = [
          ExerciseTrainingTemplateModel(
            exercise: exercise,
            order: 1,
            groupSets: [
              ExerciseSetGroupTrainingTemplateModel.uniqueFromExercise(
                exercise: exercise,
              ),
            ],
          ),
        ];

  ExerciseGroupTrainingTemplateModel.compoundFromExercise({
    required ExerciseModel exercise,
    this.order = 1,
    this.trainingTemplateId,
    this.id,
  })  : groupType = ExerciseGroupTypeEnum.compound,
        exercises = [
          ExerciseTrainingTemplateModel(
            exercise: exercise,
            order: 1,
            groupSets: [
              ExerciseSetGroupTrainingTemplateModel.multipleFromExercise(
                exercise: exercise,
                quantity: 1,
              ),
            ],
          ),
        ];

  factory ExerciseGroupTrainingTemplateModel.fromMap(Map<String, dynamic> map) {
    return ExerciseGroupTrainingTemplateModel(
      groupType: ExerciseGroupTypeEnum.fromName(map['groupType']),
      exercises: List<ExerciseTrainingTemplateModel>.from(
        (map['exercises'] as List<dynamic>).map<ExerciseTrainingTemplateModel>(
          (x) => ExerciseTrainingTemplateModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      order: map['order'] as int,
      trainingTemplateId: map['trainingTemplateId'] != null ? map['trainingTemplateId'] as int : null,
      id: map['id'] != null ? map['id'] as int : null,
    );
  }

  ExerciseGroupTrainingTemplateModel copyWith({
    ExerciseGroupTypeEnum? groupType,
    List<ExerciseTrainingTemplateModel>? exercises,
    int? order,
    ValueGetter<int?>? trainingTemplateId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseGroupTrainingTemplateModel(
      groupType: groupType ?? this.groupType,
      exercises: exercises ?? this.exercises,
      order: order ?? this.order,
      trainingTemplateId: trainingTemplateId != null ? trainingTemplateId.call() : this.trainingTemplateId,
      id: id != null ? id.call() : this.id,
    );
  }

  ExerciseGroupTrainingTemplateModel changeAndValidate({
    required List<ExerciseTrainingTemplateModel> exercises,
  }) {
    final copy = exercises.toList()..sort((a, b) => a.order.compareTo(b.order));
    return copyWith(
      exercises: List.generate(copy.length, (index) => copy[index].copyWith(order: index + 1)),
    );
  }

  ExerciseGroupTrainingTemplateModel addSimpleSet() {
    return copyWith(
      exercises: exercises.map((e) => e.addSimpleSet()).toList(),
    );
  }

  ExerciseGroupTrainingTemplateModel addMultipleSet({int quantity = 3}) {
    return copyWith(
      exercises: exercises.map((e) => e.addMultipleSet(quantity: quantity)).toList(),
    );
  }

  ExerciseGroupTrainingTemplateModel addExercise(ExerciseModel exercise) {
    return copyWith(exercises: [
      ...exercises,
      ExerciseTrainingTemplateModel(
          exercise: exercise,
          order: exercises.fold(0, (previousValue, element) => max(previousValue, element.order)) + 1,
          groupSets: List.generate(
            max(exercises.firstOrNull?.groupSets.length ?? 0, 1),
            (index) => ExerciseSetGroupTrainingTemplateModel.multipleFromExercise(
              exercise: exercise,
              quantity: index + 1,
            ),
          )),
    ]);
  }

  ExerciseGroupTrainingTemplateModel removeExercise(ExerciseTrainingTemplateModel exercise) {
    final remaining = ([...exercises]
      ..remove(exercise)
      ..sort((a, b) => a.order.compareTo(b.order)));
    final newExercises = List.generate(remaining.length, (index) => remaining.elementAt(index).copyWith(order: index + 1));

    return changeAndValidate(exercises: newExercises);
  }

  @override
  ExerciseGroupTrainingTemplateModel copyWithOrder(int order) => copyWith(order: order);

  // factory ExerciseGroupTrainingTemplateModel.fromJsonMap(Map<String, dynamic> map) {
  //   return ExerciseGroupTrainingTemplateModel(
  //     groupType: ExerciseGroupTypeEnum.fromName(map['groupType']),
  //     exercises: List<ExerciseTrainingTemplateModel>.from(
  //       (map['exercises'] as List<dynamic>).map<ExerciseTrainingTemplateModel>(
  //         (x) => ExerciseTrainingTemplateModel.fromJsonMap(x as Map<String, dynamic>),
  //       ),
  //     ),
  //     // exercises: map['exercises'] as List<ExerciseTrainingTemplateModel>,
  //     order: map['order'] as int,
  //     trainingTemplateId: map['trainingTemplateId'] != null ? map['trainingTemplateId'] as int : null,
  //     id: map['id'] != null ? map['id'] as int : null,
  //   );
  // }
  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'groupType': groupType.name,
      'order': order,
      'trainingTemplateId': trainingTemplateId,
      'id': id,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  @override
  Map<String, dynamic> toDatabase() => toMap()..remove('exercises');

  ExerciseGroupTrainingSessionModel toSession() {
    return ExerciseGroupTrainingSessionModel(
      groupType: groupType,
      exercises: exercises.map((e) => e.toSession()).toList(),
      order: order,
    );
  }
}
