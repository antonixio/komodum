import 'package:get_it/get_it.dart';
import 'package:tiggym/src/data/repository/tag_repository/tag_repository.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../initializable_repository.dart';

class HomeRepository extends InitializableRepository<HomeModel> {
  @override
  HomeModel fromMap(Map<String, dynamic> map) => HomeModel.fromMap(map);

  @override
  String get table => '';

  @override
  Future<void> load() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery("""
    SELECT
      date
    FROM training_session
    """);
    final list = maps.map((e) => DateTimeHelper.fromSecondsSinceEpoch(e['date'])).toList();
    final group = list.groupBy((p0) => p0.dateOnly);

    final tags = GetIt.I.get<TagRepository>().tagCategories.value.where((e) => e.mainTag.deletedAt == null).toList();

    final List<Map<String, dynamic>> mapsTags = await db.rawQuery("""
      SELECT
        IIF(tag.mainTag = 1, tag.id, tag.mainTagId) tagId,
        training_session.date as date
      FROM training_session
      INNER JOIN exercise_group_training_session
        ON exercise_group_training_session.trainingSessionId = training_session.id
      INNER JOIN exercise_training_session
        ON exercise_training_session.exerciseGroupTrainingSessionId = exercise_group_training_session.id
      INNER JOIN exercise
        ON exercise.id = exercise_training_session.exerciseId
      INNER JOIN tag
        ON exercise.tagId = tag.id
      WHERE
         IIF(tag.mainTag = 1, tag.id, tag.mainTagId) IN (${tags.map((e) => '?').join(',')})
    """, tags.map((e) => e.mainTag.id).toList());

    final listMaps = mapsTags
        .map((e) => {
              'date': DateTimeHelper.fromSecondsSinceEpoch(e['date']),
              'tagId': e['tagId'],
              'tag': tags
                  .firstWhere(
                    (element) => element.mainTag.id == e['tagId'],
                  )
                  .mainTag,
            })
        .groupBy((p0) => p0['tagId']);

    dataSubject.add([
      HomeModel(
        trainingSessions: group,
        traininigSessionsTags: Map<TagModel, Map<DateTime, List<DateTime>>>.fromEntries(tags.map(
          (e) => MapEntry(
            e.mainTag,
            (listMaps[e.mainTag.id] ?? []).groupBy((p0) => (p0['date'] as DateTime).dateOnly).map((key, value) => MapEntry(key, value.map((e) => e['date'] as DateTime).toList())),
          ),
        )),
      ),
    ]);
  }
}
