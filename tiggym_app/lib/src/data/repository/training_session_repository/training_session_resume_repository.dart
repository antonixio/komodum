import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../util/database/database_helper.dart';

class TrainingSessionResumeRepository {
  Future<Database> get database => DatabaseHelper.instance.database;

  String get table => 'training_session';

  Future<List<TrainingSessionResumeModel>> getSessions({String? lastOrder, int pageSize = 50}) async {
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
}
