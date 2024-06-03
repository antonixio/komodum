import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:tiggym/src/util/extensions/exercise_set_meta_training_session_model_extensions.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../util/database/database_helper.dart';
import '../crud_repository.dart';
import '../exercise_repository/exercise_repository.dart';
import '../home_repository/home_repository.dart';

class TrainingSessionRepository {
  // final repo = DefaultCrudRepository<TrainingSessionModel>(table: 'training_session', fromMap: TrainingSessionModel.fromMap);
  // final reposMeta = Map.fromEntries([
  //   DefaultCrudRepository<ExerciseSetMetaRepsTrainingSessionModel>(table: 'exercise_set_meta_reps_training_session', fromMap: ExerciseSetMetaRepsTrainingSessionModel.fromMap),
  //   DefaultCrudRepository<ExerciseSetMetaRepsAndWeightTrainingSessionModel>(
  //       table: 'exercise_set_meta_reps_and_weight_training_session', fromMap: ExerciseSetMetaRepsAndWeightTrainingSessionModel.fromMap),
  //   DefaultCrudRepository<ExerciseSetMetaTimeTrainingSessionModel>(table: 'exercise_set_time_training_session', fromMap: ExerciseSetMetaTimeTrainingSessionModel.fromMap),
  //   DefaultCrudRepository<ExerciseSetMetaDistanceTrainingSessionModel>(table: 'exercise_set_distance_training_session', fromMap: ExerciseSetMetaDistanceTrainingSessionModel.fromMap),
  //   DefaultCrudRepository<ExerciseSetMetaTimeAndDistanceTrainingSessionModel>(
  //       table: 'exercise_set_time_and_distance_training_session', fromMap: ExerciseSetMetaTimeAndDistanceTrainingSessionModel.fromMap),
  // ].map((e) => MapEntry(e.dataType, e)));

  // late final repos = Map.fromEntries(
  //   [
  //     repo,
  //     DefaultCrudRepository<ExerciseGroupTrainingSessionModel>(table: 'exercise_group_training_session', fromMap: ExerciseGroupTrainingSessionModel.fromMap),
  //     DefaultCrudRepository<ExerciseTrainingSessionModel>(table: 'exercise_training_session', fromMap: ExerciseTrainingSessionModel.fromMap),
  //     DefaultCrudRepository<ExerciseSetGroupTrainingSessionModel>(table: 'exercise_set_group_training_session', fromMap: ExerciseSetGroupTrainingSessionModel.fromMap),
  //     DefaultCrudRepository<ExerciseSetTrainingSessionModel>(table: 'exercise_set_training_session', fromMap: ExerciseSetTrainingSessionModel.fromMap),
  //     ...(reposMeta.entries.map((e) => e.value)),
  //   ].map((e) => MapEntry(e.dataType, e)),
  // );

  // String get table => 'training_template';
  // String get tableExerciseGroup => 'exercise_group_training_template';
  // String get tableExercise => 'exercise_training_template';
  // String get tableExerciseSetGroup => 'exercise_set_group_training_template';
  // String get tableExerciseSet => 'exercise_set_training_template';
  Future<Database> get database => DatabaseHelper.instance.database;

  Future<void> insert(TrainingSessionModel trainingSession) async {
    final db = await database;
    await db.transaction((txn) async {
      await _insert(txn, trainingSession);
    });
    GetIt.I.get<HomeRepository>().load();
  }

  Future<void> validateAndInsert(TrainingSessionModel trainingSession) async {
    final db = await database;
    await db.transaction((txn) async {
      final session = await GetIt.I.get<DefaultCrudRepository<TrainingSessionModel>>().getDataTransaction(
            transaction: txn,
            proxyMap: (m) => m..addAll({'exercises': []}),
            whereArgs: [trainingSession.syncId],
            whereClause: 'syncId = ?',
          );
      if (session.isEmpty) {
        await _insert(txn, trainingSession);
      }
    });
    GetIt.I.get<HomeRepository>().load();
  }

  Future<void> _insert(Transaction txn, TrainingSessionModel trainingSession) async {
    final trainingId = await _insertTransaction(trainingSession, txn);
    final note = trainingSession.note;
    if (note != null) {
      await _insertTransaction(note.copyWith(trainingSessionId: trainingId), txn);
    }

    // Inserts the exercise Groups
    for (var exGroup in trainingSession.exercises) {
      final exGroupId = await _insertTransaction(exGroup.copyWith(trainingSessionId: () => trainingId), txn);

      // Inserts the exercises within the group
      for (var exercise in exGroup.exercises) {
        final exerciseId = await _insertTransaction(exercise.copyWith(exerciseGroupTrainingSessionId: () => exGroupId), txn);

        // Inserts the set groups
        for (var groupSet in exercise.groupSets) {
          final groupSetId = await _insertTransaction(groupSet.copyWith(exerciseTrainingSessionId: () => exerciseId), txn);

          // Inserts the set within the set group
          for (var exSet in groupSet.sets) {
            final exSetId = await _insertTransaction(exSet.copyWith(exerciseSetGroupTrainingSessionId: () => groupSetId), txn);

            await exSet.meta.getDefaultCrudRepository().insertTransaction(exSet.meta.copyWithSetId(exSetId), txn);
            // await _insertTransaction(exSet.meta.copyWithSetId(exSetId), txn);
          }
        }
      }
    }
  }

  Future<List<TrainingSessionModel>> getTrainings({final int? id}) async {
    final db = await database;

    final result = await db.transaction<List<TrainingSessionModel>>((txn) async {
      final trainings = await _getTransaction<TrainingSessionModel>(
        txn,
        proxyMap: (m) => m..addAll({'exercises': []}),
        whereArgs: id != null ? [id] : null,
        whereClause: id != null ? 'id = ?' : null,
      );
      final notes = await _getTransaction<TrainingSessionNoteModel>(
        txn,
        whereArgs: trainings.map((e) => e.id).toList(),
        whereClause: 'trainingSessionId IN (${trainings.map((e) => '?').join(',')})',
      );

      final exerciseGroups = await _getTransaction<ExerciseGroupTrainingSessionModel>(txn,
          proxyMap: (m) => m..addAll({'exercises': []}), whereArgs: trainings.map((e) => e.id).toList(), whereClause: 'trainingSessionId IN (${trainings.map((e) => '?').join(',')})');
      final exercisesModel = GetIt.I.get<ExerciseRepository>().data.value;

      final exercises = await _getTransaction<ExerciseTrainingSessionModel>(
        txn,
        whereArgs: exerciseGroups.map((e) => e.id).toList(),
        proxyMap: (m) => m
          ..addAll({'groupSets': []})
          ..addAll({
            'exercise': exercisesModel
                .firstWhere(
                  (element) => element.id == m['exerciseId'],
                  orElse: () => ExerciseModel.dummy,
                )
                .toMap()
          }),
        whereClause: 'exerciseGroupTrainingSessionId IN (${exerciseGroups.map((e) => '?').join(',')})',
      );

      final setGroups = await _getTransaction<ExerciseSetGroupTrainingSessionModel>(
        txn,
        proxyMap: (m) => m
          ..addAll(
            {'sets': <ExerciseSetTrainingSessionModel>[]},
          ),
        whereArgs: exercises.map((e) => e.id).toList(),
        whereClause: 'exerciseTrainingSessionId IN (${exercises.map((e) => '?').join(',')})',
      );

      final sets = await _getTransaction<ExerciseSetTrainingSessionModel>(txn,
          proxyMap: (m) => m..addAll({'meta': ExerciseTypeEnum.fromName(m['exerciseType']).getDummyExerciseSetTrainingMetaSession().toMap()}),
          whereArgs: setGroups.map((e) => e.id).toList(),
          whereClause: 'exerciseSetGroupTrainingSessionId IN (${setGroups.map((e) => '?').join(',')})');

      final setsTypes = sets.groupBy((p) => p.exerciseType).keys.map((e) => e.getDummyExerciseSetTrainingMetaSession());
      final metas = <ExerciseSetMetaTrainingSessionModel>[];

      for (var type in setsTypes) {
        final setsMeta = await type.getDefaultCrudRepository().getDataTransaction(
              transaction: txn,
              whereArgs: sets.map((e) => e.id).toList(),
              whereClause: 'exerciseSetTrainingSessionId IN (${sets.map((e) => '?').join(',')})',
            );
        metas.addAll(setsMeta);
      }

      final trainingsFinal = <TrainingSessionModel>[];

      for (var t in trainings) {
        try {
          trainingsFinal.add(t.copyWith(
              note: () => notes.firstWhereOrNull((element) => element.trainingSessionId == t.id),
              exercises: exerciseGroups
                  .where((element) => element.trainingSessionId == t.id)
                  .map(
                    (eg) => eg.copyWith(
                        exercises: exercises
                            .where((element) => element.exerciseGroupTrainingSessionId == eg.id && element.exercise.id != ExerciseModel.dummy.id)
                            .map(
                              (e) => e.copyWith(
                                  groupSets: setGroups
                                      .where((element) => element.exerciseTrainingSessionId == e.id)
                                      .map(
                                        (sg) => sg.copyWith(
                                            sets: sets
                                                .where((element) => element.exerciseSetGroupTrainingSessionId == sg.id)
                                                .map(
                                                  (s) => s.copyWith(meta: metas.firstWhere((element) => element.exerciseSetTrainingSessionId == s.id)),
                                                )
                                                .toList()),
                                      )
                                      .toList()),
                            )
                            .toList()),
                  )
                  .toList()));
        } catch (err) {
          debugPrint("Failed to get training ${t.name} (${t.id}): $err");
        }
      }
      return trainingsFinal;
    });
    return result;
  }

  Future<int> _insertTransaction<T extends DatabaseModel>(T data, Transaction transaction) async {
    return await GetIt.I.get<DefaultCrudRepository<T>>().insertTransaction(data, transaction);
  }

  Future<List<T>> _getTransaction<T extends DatabaseModel>(
    Transaction transaction, {
    String? whereClause,
    List<dynamic>? whereArgs,
    Map<String, dynamic> Function(Map<String, dynamic>)? proxyMap,
  }) async {
    final repo = GetIt.I.get<DefaultCrudRepository<T>>();

    final data = await (repo.getDataTransaction(
      transaction: transaction,
      proxyMap: proxyMap,
      whereArgs: whereArgs,
      whereClause: whereClause,
    ));
    return data;
  }

  Future<void> update(TrainingSessionModel trainingSession) async {
    final db = await database;
    await db.transaction((txn) async {
      final repo = GetIt.I.get<DefaultCrudRepository<TrainingSessionModel>>();

      repo.updateTransaction(trainingSession, txn);
      final note = trainingSession.note;
      if (note != null && note.id > 0) {
        await GetIt.I.get<DefaultCrudRepository<TrainingSessionNoteModel>>().updateTransaction(note, txn);
      } else if (note != null) {
        await GetIt.I.get<DefaultCrudRepository<TrainingSessionNoteModel>>().insertTransaction(note.copyWith(trainingSessionId: trainingSession.id), txn);
      }
      final insertedExGroups = await _updateTransaction(
        associationColumnDelete: 'trainingSessionId',
        associationValueDelete: trainingSession.id,
        valuesUpdate: trainingSession.exercises.where((element) => element.id != null).toList(),
        valuesInsert: trainingSession.exercises.where((element) => element.id == null).map((e) => e.copyWith(trainingSessionId: () => trainingSession.id)).toList(),
        transaction: txn,
        proxyInserted: (t, id) => t.copyWith(id: () => id),
      );

      for (var exGroup in [
        ...trainingSession.exercises.where((element) => element.id != null),
        ...insertedExGroups,
      ]) {
        final insertedExercises = await _updateTransaction(
          associationValueDelete: exGroup.id,
          associationColumnDelete: 'exerciseGroupTrainingSessionId',
          valuesUpdate: exGroup.exercises.where((element) => element.id != null).toList(),
          valuesInsert: exGroup.exercises.where((element) => element.id == null).map((e) => e.copyWith(exerciseGroupTrainingSessionId: () => exGroup.id)).toList(),
          transaction: txn,
          proxyInserted: (t, id) => t.copyWith(id: () => id),
        );

        for (var exercise in [
          ...exGroup.exercises.where((element) => element.id != null),
          ...insertedExercises,
        ]) {
          final insertedGroupSets = await _updateTransaction(
            associationValueDelete: exercise.id,
            associationColumnDelete: 'exerciseTrainingSessionId',
            valuesUpdate: exercise.groupSets.where((element) => element.id != null).toList(),
            valuesInsert: exercise.groupSets.where((element) => element.id == null).map((e) => e.copyWith(exerciseTrainingSessionId: () => exercise.id)).toList(),
            transaction: txn,
            proxyInserted: (t, id) => t.copyWith(id: () => id),
          );

          for (var setGroup in [
            ...exercise.groupSets.where((element) => element.id != null),
            ...insertedGroupSets,
          ]) {
            final insertedSets = await _updateTransaction(
              associationValueDelete: setGroup.id,
              associationColumnDelete: 'exerciseSetGroupTrainingSessionId',
              valuesUpdate: setGroup.sets.where((element) => element.id != null).toList(),
              valuesInsert: setGroup.sets.where((element) => element.id == null).map((e) => e.copyWith(exerciseSetGroupTrainingSessionId: () => setGroup.id)).toList(),
              transaction: txn,
              proxyInserted: (t, id) => t.copyWith(id: () => id),
            );

            for (var exSet in [
              ...setGroup.sets.where((element) => element.id != null),
              ...insertedSets,
            ]) {
              final repo = exSet.meta.getDefaultCrudRepository();
              await repo.deleteTransaction(transaction: txn, whereClause: 'exerciseSetTrainingSessionId = ? AND id != ?', whereArgs: [exSet.id, exSet.meta.id]);
              if (exSet.meta.id == null) {
                await repo.insertTransaction(exSet.meta.copyWithSetId(exSet.id), txn);
              } else {
                await repo.updateTransaction(exSet.meta, txn);
              }
            }
          }
        }
      }
    });
    GetIt.I.get<HomeRepository>().load();
  }

  Future<List<T>> _updateTransaction<T extends DatabaseModel>({
    required dynamic associationValueDelete,
    required String associationColumnDelete,
    String columnDelete = 'id',
    required List<T> valuesUpdate,
    required List<T> valuesInsert,
    required Transaction transaction,
    required T Function(T, int) proxyInserted,
  }) async {
    final inserted = <T>[];
    final repo = GetIt.I.get<DefaultCrudRepository<T>>();
    await repo.deleteTransaction(
        transaction: transaction,
        whereClause: '$associationColumnDelete = ? AND $columnDelete NOT IN (${valuesUpdate.map((e) => '?').join(',')})',
        whereArgs: [associationValueDelete, ...valuesUpdate.map((e) => e.toDatabase()[columnDelete])]);

    for (var value in valuesUpdate) {
      await repo.updateTransaction(value, transaction);
    }

    for (var value in valuesInsert) {
      inserted.add(proxyInserted.call(value, await repo.insertTransaction(value, transaction)));
    }
    GetIt.I.get<HomeRepository>().load();

    return inserted;
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await GetIt.I.get<DefaultCrudRepository<TrainingSessionModel>>().deleteTransaction(transaction: txn, whereArgs: [id], whereClause: 'id = ?');
      GetIt.I.get<HomeRepository>().load();
    });
  }

  // Future<void> _deleteTransaction<T extends MappableModel>(String column, List<dynamic> values, Transaction transaction) async {
  //   // await repos[T]!.deleteTransaction(column, values, transaction);
  // }
}
