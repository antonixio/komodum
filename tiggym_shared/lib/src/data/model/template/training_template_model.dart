// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:tiggym_shared/src/data/model/database_model.dart';
import 'package:tiggym_shared/src/data/model/mappable_json_model.dart';

import '../../../util/extensions/date_time_extensions.dart';
import '../../../util/helper/date_time_helper.dart';
import '../../model/exercise/exercise_model.dart';
import '../../model/session/training_session_model.dart';
import '../mappable_model.dart';
import 'exercise_group_training_template_model.dart';

class TrainingTemplateModel with MappableModel, DatabaseModel {
  final int id;
  final String name;
  final List<ExerciseGroupTrainingTemplateModel> exercises;
  final DateTime? deletedAt;

  TrainingTemplateModel({
    required this.id,
    required this.name,
    required this.exercises,
    this.deletedAt,
  });

  static TrainingTemplateModel get dummy => TrainingTemplateModel(
        name: '',
        id: -1,
        exercises: [],
      );

  factory TrainingTemplateModel.fromMap(Map<String, dynamic> map) {
    return TrainingTemplateModel(
      id: map['id'] as int,
      name: map['name'] as String,
      deletedAt: map['deletedAt'] != null ? DateTimeHelper.fromSecondsSinceEpoch(map['deletedAt'] as int) : null,
      exercises: List<ExerciseGroupTrainingTemplateModel>.from(
          (map['exercises'] as List<dynamic>).map<ExerciseGroupTrainingTemplateModel>((x) => ExerciseGroupTrainingTemplateModel.fromMap(x as Map<String, dynamic>))),
    );
  }

  TrainingTemplateModel addSimpleExercise(ExerciseModel exercise) {
    return copyWith(
      exercises: [
        ...exercises,
        ExerciseGroupTrainingTemplateModel.uniqueFromExercise(
          exercise: exercise,
          order: exercises.fold(0, (previousValue, element) => max(previousValue, element.order)) + 1,
        ),
      ],
    );
  }

  TrainingTemplateModel addCompoundExercise(ExerciseModel exercise) {
    return copyWith(
      exercises: [
        ...exercises,
        ExerciseGroupTrainingTemplateModel.compoundFromExercise(
          exercise: exercise,
          order: exercises.fold(0, (previousValue, element) => max(previousValue, element.order)) + 1,
        ),
      ],
    );
  }

  TrainingTemplateModel changeAndValidate({
    required List<ExerciseGroupTrainingTemplateModel> exercises,
  }) {
    final copy = exercises.toList()..sort((a, b) => a.order.compareTo(b.order));
    return copyWith(
      exercises: List.generate(copy.length, (index) => copy[index].copyWith(order: index + 1)),
    );
  }

  TrainingTemplateModel copyWith({
    int? id,
    String? name,
    List<ExerciseGroupTrainingTemplateModel>? exercises,
    ValueGetter<DateTime?>? deletedAt,
  }) {
    return TrainingTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      deletedAt: deletedAt != null ? deletedAt.call() : this.deletedAt,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'deletedAt': deletedAt?.secondsSinceEpoch,
      'exercises': exercises.map((x) => x.toMap()).toList(),
    };
  }

  @override
  Map<String, dynamic> toDatabase() => toMap()..remove('exercises');

  TrainingSessionModel toSession() {
    return TrainingSessionModel(
      trainingTemplateId: id,
      name: name,
      exercises: exercises.map((e) => e.toSession()).toList(),
      date: DateTime.now(),
      duration: Duration.zero,
    );
  }
}
