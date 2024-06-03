import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tiggym_shared/src/data/model/database_model.dart';
import 'package:tiggym_shared/src/util/extensions/map_extensions.dart';

import '../../enum/exercise_set_group_type_enum.dart';
import '../exercise/exercise_model.dart';
import '../mappable_model.dart';
import '../orderable_model.dart';
import '../session/exercise_training_session_model.dart';
import 'exercise_set_group_training_template_model.dart';

class ExerciseTrainingTemplateModel with MappableModel, DatabaseModel, OrderableModel<ExerciseTrainingTemplateModel> {
  final ExerciseModel exercise;
  final List<ExerciseSetGroupTrainingTemplateModel> groupSets;
  @override
  final int order;
  final int? exerciseGroupTrainingTemplateId;
  final int? id;

  ExerciseTrainingTemplateModel({
    required this.exercise,
    required this.order,
    required this.groupSets,
    this.exerciseGroupTrainingTemplateId,
    this.id,
  });

  factory ExerciseTrainingTemplateModel.fromMap(Map<String, dynamic> map) {
    return ExerciseTrainingTemplateModel(
      exercise: ExerciseModel.fromMap(map['exercise']),
      groupSets: List<ExerciseSetGroupTrainingTemplateModel>.from(
        (map['groupSets'] as List<dynamic>).map<ExerciseSetGroupTrainingTemplateModel>((x) => ExerciseSetGroupTrainingTemplateModel.fromMap(x as Map<String, dynamic>)),
      ),
      order: map['order'] as int,
      exerciseGroupTrainingTemplateId: map['exerciseGroupTrainingTemplateId'] != null ? map['exerciseGroupTrainingTemplateId'] as int : null,
      id: map['id'] != null ? map['id'] as int : null,
    );
  }

  ExerciseTrainingTemplateModel copyWith({
    ExerciseModel? exercise,
    List<ExerciseSetGroupTrainingTemplateModel>? groupSets,
    int? order,
    ValueGetter<int?>? exerciseGroupTrainingTemplateId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseTrainingTemplateModel(
      exercise: exercise ?? this.exercise,
      order: order ?? this.order,
      groupSets: groupSets ?? this.groupSets,
      exerciseGroupTrainingTemplateId: exerciseGroupTrainingTemplateId != null ? exerciseGroupTrainingTemplateId.call() : this.exerciseGroupTrainingTemplateId,
      id: id != null ? id.call() : this.id,
    );
  }

  ExerciseTrainingTemplateModel changeAndValidate({
    required List<ExerciseSetGroupTrainingTemplateModel> groupSets,
  }) {
    final copy = groupSets.where((element) => element.sets.isNotEmpty).toList()..sort((a, b) => a.order.compareTo(b.order));
    return copyWith(
      groupSets: List.generate(copy.length, (index) => copy[index].copyWith(order: index + 1)),
    );
  }

  ExerciseTrainingTemplateModel.dummy({
    required this.exercise,
    this.order = 1,
    this.exerciseGroupTrainingTemplateId,
    this.id,
  }) : groupSets = [
          ExerciseSetGroupTrainingTemplateModel.uniqueFromExercise(
            exercise: exercise,
          ),
        ];

  ExerciseTrainingTemplateModel addSimpleSet() {
    ExerciseSetGroupTrainingTemplateModel? last = groupSets.lastOrNull;
    last = last?.groupType == ExerciseSetGroupTypeEnum.unique ? last : null;

    final groupSet = last != null
        ? last.duplicate()
        : ExerciseSetGroupTrainingTemplateModel.uniqueFromExercise(
            exercise: exercise,
          );
    return copyWith(
      groupSets: [
        ...groupSets,
        groupSet.copyWith(
          order: groupSets.fold(0, (previousValue, element) => max(previousValue, element.order)) + 1,
        ),
      ],
    );
  }

  ExerciseTrainingTemplateModel addMultipleSet({int quantity = 3}) {
    ExerciseSetGroupTrainingTemplateModel? last = groupSets.lastOrNull;
    last = last?.groupType == ExerciseSetGroupTypeEnum.multiple ? last : null;

    final groupSet = last != null
        ? last.duplicate()
        : ExerciseSetGroupTrainingTemplateModel.multipleFromExercise(
            exercise: exercise,
            quantity: quantity,
          );
    if (last != null) {}
    return copyWith(
      groupSets: [
        ...groupSets,
        groupSet.copyWith(
          order: groupSets.fold(0, (previousValue, element) => max(previousValue, element.order)) + 1,
        ),
      ],
    );
  }

  ExerciseTrainingSessionModel toSession() {
    return ExerciseTrainingSessionModel(
      exercise: exercise,
      order: order,
      groupSets: groupSets.map((e) => e.toSession()).toList(),
    );
  }

  @override
  ExerciseTrainingTemplateModel copyWithOrder(int order) => copyWith(order: order);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'exercise': exercise.toMap(),
      'order': order,
      'exerciseGroupTrainingTemplateId': exerciseGroupTrainingTemplateId,
      'id': id,
      'groupSets': groupSets.map((e) => e.toMap()).toList()
    };
  }

  @override
  Map<String, dynamic> toDatabase() => toMap()
    ..remove('exercise')
    ..remove('groupSets')
    ..addOrUpdate({'exerciseId': exercise.id});
}
