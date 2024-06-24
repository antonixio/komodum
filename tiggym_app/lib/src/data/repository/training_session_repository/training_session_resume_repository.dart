import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tiggym/src/data/repository/tag_repository/tag_repository.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../util/database/database_helper.dart';

class TrainingSessionResumeRepository {
  Future<Database> get database => DatabaseHelper.instance.database;

  String get table => 'training_session';

  Future<List<TrainingSessionResumeModel>> getSessionsA({String? lastOrder, int pageSize = 50}) async {
    try {
      final db = await database;
      return await db.transaction((txn) async {
        final lastOrder0 = lastOrder ?? '';
        final where = lastOrder0.isNotEmpty ? '"order" < ?' : null;
        final whereArgs = lastOrder0.isNotEmpty ? [lastOrder0] : null;
        final maps = await txn.query(table, where: where, whereArgs: whereArgs, limit: pageSize, orderBy: '"order" desc');

        final tagsMaps = await txn.rawQuery("""
          SELECT
            exercise_group_training_session.trainingSessionId,
            tag.*
          FROM exercise_group_training_session
          INNER JOIN exercise_training_session
            ON exercise_training_session.exerciseGroupTrainingSessionId = exercise_group_training_session.id
          INNER JOIN exercise
            ON exercise.id = exercise_training_session.exerciseId
          INNER JOIN tag
            ON tag.id = exercise.tagId
          WHERE exercise_group_training_session.trainingSessionId IN ({trainingIds})
          GROUP BY exercise_group_training_session.trainingSessionId, tag.id
        """
            .replaceAll('{trainingIds}', maps.map((e) => e['id'] as int).toList().join(",")));
        final trainingTags = tagsMaps
            .map((e) => {
                  'trainingSessionId': e['trainingSessionId'],
                  'tag': TagModel.fromMap(e),
                })
            .toList()
            .groupBy((p0) => p0['trainingSessionId'] as int);

        return maps.map((e) {
          return TrainingSessionResumeModel.fromMap(Map.from(e)
            ..addAll(
              {
                'tags': (trainingTags[e['id']] ?? <Map<String, Object?>>[]).map((e) => e['tag'] as TagModel).toList(),
              },
            ));
        }).toList();
      });
    } catch (err) {
      debugPrint(err.toString());
      return [];
    }
  }

  Future<List<TrainingSessionResumeModel>> getSessions({String? lastOrder, int pageSize = 50}) async {
    try {
      int start = int.tryParse(lastOrder ?? '') ?? 0;

      return List.generate(pageSize, (index) {
        final tags = List.generate(4, (index) => GetIt.I.get<TagRepository>().tagCategories.value.randomItem()!.mainTag).groupBy((p0) => p0.id).entries.map((e) => e.value.first).toList();
        return TrainingSessionResumeModel(
            id: index + start + 1,
            name: "${tags.first.name} Workout",
            date: DateTime.now().add(Duration(days: -(index + start), minutes: -(Random().nextInt(60 * 3)))),
            duration: Duration(minutes: Random().nextInt(45) + 45),
            order: (index + start).toString(),
            tags: tags);
      });
    } catch (err) {
      debugPrint(err.toString());
      return [];
    }
  }
}
