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
    dataSubject.add([HomeModel(trainingSessions: group)]);
  }
}
