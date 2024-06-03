import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:tiggym_shared/src/data/model/database_model.dart';
import '../orderable_model.dart';
import 'exercise_group_training_session_model.dart';
import '../../../util/extensions/map_extensions.dart';
import '../../enum/exercise_set_group_type_enum.dart';
import '../exercise/exercise_model.dart';
import '../mappable_model.dart';
import '../template/exercise_set_group_training_template_model.dart';

import 'exercise_set_group_training_session_model.dart';

class ExerciseTrainingSessionModel with MappableModel, DatabaseModel, OrderableModel<ExerciseTrainingSessionModel> {
  final ExerciseModel exercise;
  final List<ExerciseSetGroupTrainingSessionModel> groupSets;
  @override
  final int order;
  final int? exerciseGroupTrainingSessionId;
  final int? id;

  ExerciseTrainingSessionModel({
    required this.exercise,
    required this.order,
    required this.groupSets,
    this.exerciseGroupTrainingSessionId,
    this.id,
  });

  ExerciseTrainingSessionModel.dummy({
    required this.exercise,
    this.order = 1,
    this.exerciseGroupTrainingSessionId,
    this.id,
  }) : groupSets = [
          ExerciseSetGroupTrainingSessionModel.uniqueFromExercise(
            exercise: exercise,
          ),
        ];

  factory ExerciseTrainingSessionModel.fromMap(Map<String, dynamic> map) {
    return ExerciseTrainingSessionModel(
      exercise: ExerciseModel.fromMap(map['exercise']),
      groupSets: (map['groupSets'] as List<dynamic>).map((e) => ExerciseSetGroupTrainingSessionModel.fromMap(e)).toList(),
      order: map['order'] as int,
      exerciseGroupTrainingSessionId: map['exerciseGroupTrainingSessionId'] != null ? map['exerciseGroupTrainingSessionId'] as int : null,
      id: map['id'] != null ? map['id'] as int : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'exerciseId': exercise.id,
      'order': order,
      'exerciseGroupTrainingSessionId': exerciseGroupTrainingSessionId,
      'id': id,
      'groupSets': groupSets.map((e) => e.toMap()).toList(),
      'exercise': exercise.toMap(),
    };
  }

  @override
  Map<String, dynamic> toDatabase() => toMap()
    ..remove('groupSets')
    ..remove('exercise');

  ExerciseTrainingSessionModel copyWith({
    ExerciseModel? exercise,
    List<ExerciseSetGroupTrainingSessionModel>? groupSets,
    int? order,
    ValueGetter<int?>? exerciseGroupTrainingSessionId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseTrainingSessionModel(
      exercise: exercise ?? this.exercise,
      order: order ?? this.order,
      groupSets: groupSets ?? this.groupSets,
      exerciseGroupTrainingSessionId: exerciseGroupTrainingSessionId != null ? exerciseGroupTrainingSessionId.call() : this.exerciseGroupTrainingSessionId,
      id: id != null ? id.call() : this.id,
    );
  }

  ExerciseTrainingSessionModel changeAndValidate({
    required List<ExerciseSetGroupTrainingSessionModel> groupSets,
  }) {
    final copy = groupSets.where((element) => element.sets.isNotEmpty).toList()..sort((a, b) => a.order.compareTo(b.order));
    return copyWith(
      groupSets: List.generate(copy.length, (index) => copy[index].copyWith(order: index + 1)),
    );
  }

  ExerciseTrainingSessionModel addSimpleSet() {
    ExerciseSetGroupTrainingSessionModel? last = groupSets.lastOrNull;
    last = last?.groupType == ExerciseSetGroupTypeEnum.unique ? last : null;

    final groupSet = last != null
        ? last.duplicate()
        : ExerciseSetGroupTrainingSessionModel.uniqueFromExercise(
            exercise: exercise,
          );
    return copyWith(
      groupSets: [
        ...groupSets,
        groupSet.copyWith(
          id: () => null,
          order: groupSets.fold(0, (previousValue, element) => max(previousValue, element.order)) + 1,
        ),
      ],
    );
  }

  ExerciseTrainingSessionModel addMultipleSet({int quantity = 3}) {
    ExerciseSetGroupTrainingSessionModel? last = groupSets.lastOrNull;
    last = last?.groupType == ExerciseSetGroupTypeEnum.multiple ? last : null;

    final groupSet = last != null
        ? last.duplicate()
        : ExerciseSetGroupTrainingSessionModel.multipleFromExercise(
            exercise: exercise,
            quantity: quantity,
          );
    if (last != null) {}
    return copyWith(
      groupSets: [
        ...groupSets,
        groupSet.copyWith(
          id: () => null,
          order: groupSets.fold(0, (previousValue, element) => max(previousValue, element.order)) + 1,
        ),
      ],
    );
  }

  @override
  ExerciseTrainingSessionModel copyWithOrder(int order) => copyWith(order: order);
}
