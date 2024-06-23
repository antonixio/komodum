import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:tiggym/src/util/extensions/exercise_set_meta_training_session_template_extensions.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../util/database/database_helper.dart';
import '../crud_repository.dart';
import '../exercise_repository/exercise_repository.dart';

class TrainingTemplateRepository {
  Future<Database> get database => DatabaseHelper.instance.database;

  Future<int?> insert(TrainingTemplateModel trainingTemplate) async {
    final db = await database;
    return await db.transaction((txn) async {
      final trainingId = await _insertTransaction(trainingTemplate, txn);

      // Inserts the exercise Groups
      for (var exGroup in trainingTemplate.exercises) {
        final exGroupId = await _insertTransaction(exGroup.copyWith(trainingTemplateId: () => trainingId), txn);

        // Inserts the exercises within the group
        for (var exercise in exGroup.exercises) {
          final exerciseId = await _insertTransaction(exercise.copyWith(exerciseGroupTrainingTemplateId: () => exGroupId), txn);

          // Inserts the set groups
          for (var groupSet in exercise.groupSets) {
            final groupSetId = await _insertTransaction(groupSet.copyWith(exerciseTrainingTemplateId: () => exerciseId), txn);

            // Inserts the set within the set group
            for (var exSet in groupSet.sets) {
              final exSetId = await _insertTransaction(exSet.copyWith(exerciseSetGroupTrainingTemplateId: () => groupSetId), txn);

              await exSet.meta.getDefaultCrudRepository().insertTransaction(exSet.meta.copyWithSetId(exSetId), txn);
            }
          }
        }
      }

      return trainingId;
    });
  }

  Future<List<TrainingTemplateModel>> getTrainings({final int? id}) async {
    final db = await database;

    final result = await db.transaction<List<TrainingTemplateModel>>((txn) async {
      final trainings = await _getTransaction<TrainingTemplateModel>(
        txn,
        proxyMap: (m) => m..addAll({'exercises': []}),
        whereArgs: id != null ? [id] : null,
        whereClause: id != null ? 'id = ? AND coalesce(deletedAt, 0) = 0' : 'coalesce(deletedAt, 0) = 0',
      );

      final exerciseGroups = await _getTransaction<ExerciseGroupTrainingTemplateModel>(txn,
          orderBy: '"order"',
          proxyMap: (m) => m..addAll({'exercises': []}),
          whereArgs: trainings.map((e) => e.id).toList(),
          whereClause: 'trainingTemplateId IN (${trainings.map((e) => '?').join(',')})');
      final exercisesModel = GetIt.I.get<ExerciseRepository>().data.value;

      final exercises = await _getTransaction<ExerciseTrainingTemplateModel>(
        txn,
        orderBy: '"order"',
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
        whereClause: 'exerciseGroupTrainingTemplateId IN (${exerciseGroups.map((e) => '?').join(',')})',
      );

      final setGroups = await _getTransaction<ExerciseSetGroupTrainingTemplateModel>(
        txn,
        orderBy: '"order"',
        proxyMap: (m) => m
          ..addAll(
            {'sets': []},
          ),
        whereArgs: exercises.map((e) => e.id).toList(),
        whereClause: 'exerciseTrainingTemplateId IN (${exercises.map((e) => '?').join(',')})',
      );

      final sets = await _getTransaction<ExerciseSetTrainingTemplateModel>(txn,
          orderBy: '"order"',
          proxyMap: (m) => m..addAll({'meta': ExerciseTypeEnum.fromName(m['exerciseType']).getDummyExerciseSetTrainingMetaTemplate().toMap()}),
          whereArgs: setGroups.map((e) => e.id).toList(),
          whereClause: 'exerciseSetGroupTrainingTemplateId IN (${setGroups.map((e) => '?').join(',')})');

      final setsTypes = sets.groupBy((p) => p.exerciseType).keys.map((e) => e.getDummyExerciseSetTrainingMetaTemplate());
      final metas = <ExerciseSetMetaTrainingTemplateModel>[];

      for (var type in setsTypes) {
        final setsMeta = await type.getDefaultCrudRepository().getDataTransaction(
              transaction: txn,
              whereArgs: sets.map((e) => e.id).toList(),
              whereClause: 'exerciseSetTrainingTemplateId IN (${sets.map((e) => '?').join(',')})',
            );
        metas.addAll(setsMeta);
      }

      final trainingsFinal = <TrainingTemplateModel>[];

      for (var t in trainings) {
        try {
          trainingsFinal.add(t.copyWith(
              exercises: exerciseGroups
                  .where((element) => element.trainingTemplateId == t.id)
                  .map(
                    (eg) => eg.copyWith(
                        exercises: exercises
                            .where((element) => element.exerciseGroupTrainingTemplateId == eg.id && element.exercise.id != ExerciseModel.dummy.id)
                            .map(
                              (e) => e.copyWith(
                                  groupSets: setGroups
                                      .where((element) => element.exerciseTrainingTemplateId == e.id)
                                      .map(
                                        (sg) => sg.copyWith(
                                            sets: sets
                                                .where((element) => element.exerciseSetGroupTrainingTemplateId == sg.id)
                                                .map(
                                                  (s) => s.copyWith(meta: metas.firstWhere((element) => element.exerciseSetTrainingTemplateId == s.id)),
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
    String? orderBy,
  }) async {
    final repo = GetIt.I.get<DefaultCrudRepository<T>>();

    final data = await (repo.getDataTransaction(
      transaction: transaction,
      proxyMap: proxyMap,
      whereArgs: whereArgs,
      whereClause: whereClause,
      orderBy: orderBy,
    ));
    return data;
  }

  Future<void> update(TrainingTemplateModel trainingTemplate) async {
    final db = await database;
    await db.transaction((txn) async {
      final repo = GetIt.I.get<DefaultCrudRepository<TrainingTemplateModel>>();

      repo.updateTransaction(trainingTemplate, txn);

      final insertedExGroups = await _updateTransaction(
        associationColumnDelete: 'trainingTemplateId',
        associationValueDelete: trainingTemplate.id,
        valuesUpdate: trainingTemplate.exercises.where((element) => element.id != null).toList(),
        valuesInsert: trainingTemplate.exercises.where((element) => element.id == null).map((e) => e.copyWith(trainingTemplateId: () => trainingTemplate.id)).toList(),
        transaction: txn,
        proxyInserted: (t, id) => t.copyWith(id: () => id),
      );

      for (var exGroup in [
        ...trainingTemplate.exercises.where((element) => element.id != null),
        ...insertedExGroups,
      ]) {
        final insertedExercises = await _updateTransaction(
          associationValueDelete: exGroup.id,
          associationColumnDelete: 'exerciseGroupTrainingTemplateId',
          valuesUpdate: exGroup.exercises.where((element) => element.id != null).toList(),
          valuesInsert: exGroup.exercises.where((element) => element.id == null).map((e) => e.copyWith(exerciseGroupTrainingTemplateId: () => exGroup.id)).toList(),
          transaction: txn,
          proxyInserted: (t, id) => t.copyWith(id: () => id),
        );

        for (var exercise in [
          ...exGroup.exercises.where((element) => element.id != null),
          ...insertedExercises,
        ]) {
          final insertedGroupSets = await _updateTransaction(
            associationValueDelete: exercise.id,
            associationColumnDelete: 'exerciseTrainingTemplateId',
            valuesUpdate: exercise.groupSets.where((element) => element.id != null).toList(),
            valuesInsert: exercise.groupSets.where((element) => element.id == null).map((e) => e.copyWith(exerciseTrainingTemplateId: () => exercise.id)).toList(),
            transaction: txn,
            proxyInserted: (t, id) => t.copyWith(id: () => id),
          );

          for (var setGroup in [
            ...exercise.groupSets.where((element) => element.id != null),
            ...insertedGroupSets,
          ]) {
            final insertedSets = await _updateTransaction(
              associationValueDelete: setGroup.id,
              associationColumnDelete: 'exerciseSetGroupTrainingTemplateId',
              valuesUpdate: setGroup.sets.where((element) => element.id != null).toList(),
              valuesInsert: setGroup.sets.where((element) => element.id == null).map((e) => e.copyWith(exerciseSetGroupTrainingTemplateId: () => setGroup.id)).toList(),
              transaction: txn,
              proxyInserted: (t, id) => t.copyWith(id: () => id),
            );

            for (var exSet in [
              ...setGroup.sets.where((element) => element.id != null),
              ...insertedSets,
            ]) {
              final repo = exSet.meta.getDefaultCrudRepository();
              await repo.deleteTransaction(transaction: txn, whereClause: 'exerciseSetTrainingTemplateId = ? AND id != ?', whereArgs: [exSet.id, exSet.meta.id]);
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

    return inserted;
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      final repo = GetIt.I.get<DefaultCrudRepository<TrainingTemplateModel>>();
      await repo.updateSpecificTransaction({'deletedAt': DateTime.now().secondsSinceEpoch}, id, txn);
    });
  }

  // Future<void> _deleteTransaction<T extends MappableModel>(String column, List<dynamic> values, Transaction transaction) async {
  //   // await repos[T]!.deleteTransaction(column, values, transaction);
  // }
}
