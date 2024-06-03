import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tiggym_shared/src/data/model/database_model.dart';
import '../orderable_model.dart';

import '../../../util/extensions/iterable_extensions.dart';
import '../../enum/exercise_set_group_type_enum.dart';
import '../exercise/exercise_model.dart';
import '../mappable_model.dart';
import '../session/exercise_set_group_training_session_model.dart';
import 'exercise_set_training_template_model.dart';

class ExerciseSetGroupTrainingTemplateModel with MappableModel, DatabaseModel, OrderableModel<ExerciseSetGroupTrainingTemplateModel> {
  final ExerciseSetGroupTypeEnum groupType;
  final List<ExerciseSetTrainingTemplateModel> sets;
  @override
  final int order;
  final int? exerciseTrainingTemplateId;
  final int? id;

  ExerciseSetGroupTrainingTemplateModel({
    required this.groupType,
    required this.sets,
    required this.order,
    this.exerciseTrainingTemplateId,
    this.id,
  });

  ExerciseSetGroupTrainingTemplateModel.uniqueFromExercise({
    required ExerciseModel exercise,
    this.order = 1,
    this.exerciseTrainingTemplateId,
    this.id,
  })  : groupType = ExerciseSetGroupTypeEnum.unique,
        sets = [
          ExerciseSetTrainingTemplateModel(
            meta: exercise.type.getDummyExerciseSetTrainingMetaTemplate(),
            exerciseType: exercise.type,
            order: 1,
          ),
        ];

  ExerciseSetGroupTrainingTemplateModel.multipleFromExercise({
    required ExerciseModel exercise,
    this.order = 1,
    int quantity = 3,
    this.exerciseTrainingTemplateId,
    this.id,
  })  : groupType = ExerciseSetGroupTypeEnum.multiple,
        sets = List.generate(
            quantity,
            (index) => ExerciseSetTrainingTemplateModel(
                  meta: exercise.type.getDummyExerciseSetTrainingMetaTemplate(),
                  exerciseType: exercise.type,
                  order: index + 1,
                ));

  factory ExerciseSetGroupTrainingTemplateModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSetGroupTrainingTemplateModel(
      groupType: ExerciseSetGroupTypeEnum.fromName(map['groupType']),
      sets: List<ExerciseSetTrainingTemplateModel>.from(
        (map['sets'] as List<dynamic>).map<ExerciseSetTrainingTemplateModel>((x) => ExerciseSetTrainingTemplateModel.fromMap(x as Map<String, dynamic>)),
      ),
      order: map['order'] as int,
      exerciseTrainingTemplateId: map['exerciseTrainingTemplateId'] != null ? map['exerciseTrainingTemplateId'] as int : null,
      id: map['id'] != null ? map['id'] as int : null,
    );
  }

  ExerciseSetGroupTrainingTemplateModel copyWith({
    ExerciseSetGroupTypeEnum? groupType,
    List<ExerciseSetTrainingTemplateModel>? sets,
    int? order,
    ValueGetter<int?>? exerciseTrainingTemplateId,
    ValueGetter<int?>? id,
  }) {
    return ExerciseSetGroupTrainingTemplateModel(
      groupType: groupType ?? this.groupType,
      sets: sets ?? this.sets,
      order: order ?? this.order,
      exerciseTrainingTemplateId: exerciseTrainingTemplateId != null ? exerciseTrainingTemplateId.call() : this.exerciseTrainingTemplateId,
      id: id != null ? id.call() : this.id,
    );
  }

  ExerciseSetGroupTrainingTemplateModel duplicate() {
    return copyWith(
      id: () => null,
      sets: sets.map((e) => e.duplicate()).toList(),
    );
  }

  ExerciseSetGroupTrainingTemplateModel changeAndValidate({
    required List<ExerciseSetTrainingTemplateModel> sets,
  }) {
    final copy = [...sets]..sort((a, b) => a.order.compareTo(b.order));
    return copyWith(
      sets: List.generate(copy.length, (index) => copy[index].copyWith(order: index + 1)),
    );
  }

  ExerciseSetGroupTrainingTemplateModel removeSet(ExerciseSetTrainingTemplateModel exerciseSet) {
    final remaining = ([...sets]
      ..remove(exerciseSet)
      ..sort((a, b) => a.order.compareTo(b.order)));
    final newSets = List.generate(remaining.length, (index) => remaining.elementAt(index).copyWith(order: index + 1));

    return changeAndValidate(sets: newSets);
  }

  ExerciseSetGroupTrainingTemplateModel updateSet(ExerciseSetTrainingTemplateModel current, ExerciseSetTrainingTemplateModel newSet) {
    return changeAndValidate(sets: sets.replaceWith(current, newSet).toList());
  }

  ExerciseSetGroupTrainingTemplateModel addInnerSet() {
    return copyWith(sets: [
      ...sets,
      ExerciseSetTrainingTemplateModel(
        meta: sets.last.exerciseType.getDummyExerciseSetTrainingMetaTemplate(),
        exerciseType: sets.last.exerciseType,
        order: sets.fold(0, (previousValue, element) => max(previousValue, element.order)) + 1,
      ),
    ]);
  }

  ExerciseSetGroupTrainingSessionModel toSession() {
    return ExerciseSetGroupTrainingSessionModel(
      groupType: groupType,
      order: order,
      sets: sets.map((e) => e.toSession()).toList(),
    );
  }

  @override
  ExerciseSetGroupTrainingTemplateModel copyWithOrder(int order) => copyWith(order: order);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'groupType': groupType.name, 'order': order, 'exerciseTrainingTemplateId': exerciseTrainingTemplateId, 'id': id, 'sets': sets.map((e) => e.toMap()).toList()};
  }

  @override
  Map<String, dynamic> toDatabase() => toMap()..remove('sets');
}
