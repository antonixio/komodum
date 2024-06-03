import 'package:flutter/material.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../initializable_repository.dart';

class TrainingTemplateResumeRepository extends InitializableRepository<TrainingTemplateResumeModel> {
  @override
  String get table => 'training_template';

  @override
  Future<void> load() async {
    final db = await database;
    try {
      final list = await db.transaction((txn) async {
        final List<Map<String, dynamic>> maps = await txn.query(table);

        final tagsMaps = await txn.rawQuery("""
          SELECT
            exercise_group_training_template.trainingTemplateId,
            tag.*
          FROM exercise_group_training_template
          INNER JOIN exercise_training_template
            ON exercise_training_template.exerciseGrouptrainingTemplateId = exercise_group_training_template.id
          INNER JOIN exercise
            ON exercise.id = exercise_training_template.exerciseId
          INNER JOIN tag
            ON tag.id = exercise.tagId
          WHERE exercise_group_training_template.trainingTemplateId IN ({trainingIds})
          GROUP BY exercise_group_training_template.trainingTemplateId, tag.id
        """
            .replaceAll('{trainingIds}', maps.map((e) => e['id'] as int).toList().join(",")));
        final trainingTags = tagsMaps
            .map((e) => {
                  'trainingTemplateId': e['trainingTemplateId'],
                  'tag': TagModel.fromMap(e),
                })
            .toList()
            .groupBy((p0) => p0['trainingTemplateId'] as int);

        final datesMaps = await txn.rawQuery("""
          SELECT
            training_template.id as trainingTemplateId,
            training_session.date as date
          FROM training_session
          INNER JOIN training_template
            ON training_template.id = training_session.trainingTemplateId
          WHERE training_template.id IN ({trainingIds})
        """
            .replaceAll('{trainingIds}', maps.map((e) => e['id'] as int).toList().join(",")));
        final trainingDates = datesMaps
            .map((e) => {
                  'trainingTemplateId': e['trainingTemplateId'],
                  'date': DateTimeHelper.fromSecondsSinceEpoch(e['date'] as int),
                })
            .toList()
            .groupBy((p0) => p0['trainingTemplateId'] as int);

        return maps.map((e) {
          return fromMap(Map.from(e)
            ..addAll(
              {
                'tags': (trainingTags[e['id']] ?? <Map<String, Object?>>[]).map((e) => e['tag'] as TagModel).toList(),
                'lastSessions': (trainingDates[e['id']] ?? <Map<String, Object?>>[]).map((e) => e['date'] as DateTime).toList(),
              },
            ));
        }).toList();
      });
      dataSubject.add(list);
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  @override
  TrainingTemplateResumeModel fromMap(Map<String, dynamic> map) => TrainingTemplateResumeModel.fromMap(map);
}
