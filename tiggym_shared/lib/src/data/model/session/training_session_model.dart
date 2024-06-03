// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tiggym_shared/src/data/model/database_model.dart';
import 'package:tiggym_shared/src/util/all.dart';

import '../../../data/model/exercise/exercise_model.dart';
import '../../../data/model/session/training_session_note_model.dart';
import '../../../util/extensions/date_time_extensions.dart';
import '../../../util/extensions/map_extensions.dart';
import '../../../util/helper/date_time_helper.dart';
import '../mappable_model.dart';
import 'exercise_group_training_session_model.dart';

class TrainingSessionModel with MappableModel, DatabaseModel {
  final String? syncId;
  final int? id;
  final String name;
  final DateTime date;
  final int? trainingTemplateId;
  final List<ExerciseGroupTrainingSessionModel> exercises;
  final Duration duration;
  final TrainingSessionNoteModel? note;

  TrainingSessionModel({
    this.id,
    String? syncId,
    required this.name,
    required this.exercises,
    this.trainingTemplateId,
    required this.date,
    required this.duration,
    this.note,
  }) : syncId = syncId ?? UuidService.instance.uuid();

  static TrainingSessionModel get dummy => TrainingSessionModel(
        name: '',
        id: -1,
        exercises: [],
        date: DateTime.now(),
        duration: Duration.zero,
      );

  factory TrainingSessionModel.fromMap(Map<String, dynamic> map) {
    return TrainingSessionModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      syncId: map['syncId'] as String,
      date: DateTimeHelper.fromSecondsSinceEpoch(map['date']),
      trainingTemplateId: map['trainingTemplateId'],
      duration: Duration(seconds: map['duration']),
      note: map['note'] != null ? TrainingSessionNoteModel.fromMap(map['note']) : null,
      exercises: (map['exercises'] as List<dynamic>).map((e) => ExerciseGroupTrainingSessionModel.fromMap(e)).toList(),
    );
  }
  TrainingSessionModel addSimpleExercise(ExerciseModel exercise) {
    return copyWith(
      exercises: [
        ...exercises,
        ExerciseGroupTrainingSessionModel.uniqueFromExercise(
          exercise: exercise,
          order: exercises.fold(0, (previousValue, element) => max(previousValue, element.order)) + 1,
        ),
      ],
    );
  }

  TrainingSessionModel addCompoundExercise(ExerciseModel exercise) {
    return copyWith(
      exercises: [
        ...exercises,
        ExerciseGroupTrainingSessionModel.compoundFromExercise(
          exercise: exercise,
          order: exercises.fold(0, (previousValue, element) => max(previousValue, element.order)) + 1,
        ),
      ],
    );
  }

  TrainingSessionModel changeAndValidate({
    required List<ExerciseGroupTrainingSessionModel> exercises,
  }) {
    final copy = exercises.toList()..sort((a, b) => a.order.compareTo(b.order));
    return copyWith(
      exercises: List.generate(copy.length, (index) => copy[index].copyWith(order: index + 1)),
      syncId: () => syncId,
    );
  }

  TrainingSessionModel copyWith({
    ValueGetter<int?>? id,
    String? name,
    List<ExerciseGroupTrainingSessionModel>? exercises,
    DateTime? date,
    ValueGetter<int?>? trainingTemplateId,
    ValueGetter<String?>? syncId,
    Duration? duration,
    ValueGetter<TrainingSessionNoteModel?>? note,
  }) {
    return TrainingSessionModel(
      id: id != null ? id.call() : this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      trainingTemplateId: trainingTemplateId != null ? trainingTemplateId.call() : this.trainingTemplateId,
      note: note != null ? note.call() : this.note,
      syncId: syncId != null ? syncId.call() : this.syncId,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'trainingTemplateId': trainingTemplateId,
      'duration': duration.inSeconds,
      'date': date.secondsSinceEpoch,
      'exercises': exercises.map((x) => x.toMap()).toList(),
      'note': note?.toMap(),
      'syncId': syncId
    };
  }

  @override
  Map<String, dynamic> toDatabase() => toMap()
    ..remove('exercises')
    ..remove('note');
}
