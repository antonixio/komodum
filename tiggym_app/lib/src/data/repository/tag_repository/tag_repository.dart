import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../initializable_repository.dart';
import '../stream_crud_repository.dart';

class TagRepository extends InitializableRepository<TagModel> with StreamCrudRepository<TagModel, int> {
  @override
  String get table => 'tag';

  ValueStream<List<TagCategoryModel>> get tagCategories => _tagCategories.shareValueSeeded(_getCategories(data.value));

  late final _tagCategories = dataSubject.map<List<TagCategoryModel>>(_getCategories);

  List<TagCategoryModel> _getCategories(List<TagModel> tags) {
    final mainTags = tags.where((element) => element.mainTag).where((element) => element.deletedAt == null).toList();
    return mainTags.map((e) => TagCategoryModel(mainTag: e, list: tags.where((element) => element.mainTagId == e.id).where((element) => element.deletedAt == null).toList())).toList();
  }

  @override
  TagModel fromMap(Map<String, dynamic> map) => TagModel.fromMap(map);

  Future<void> updateAndValidateUnder(
    TagModel data,
    int pkValue, {
    bool changeUnder = false,
  }) async {
    final db = await database;
    final batch = db.batch();
    batch.update(table, data.toMap()..remove(pk), where: '$pk = ?', whereArgs: [pkValue]);
    if (data.mainTagId != null) {
      batch.update(table, data.toMap().filtered(['mainTagId', 'color']), where: 'mainTagId = ?', whereArgs: [pkValue]);
    }
    await batch.commit();
    await load();
  }

  @override
  Future<void> delete(int pkValue) async {
    await updateSpecific(
      {'deletedAt': DateTime.now().secondsSinceEpoch},
      pkValue,
    );
    final db = await database;
    await db.update(table, {'mainTagId': null}, where: 'mainTagId = ?', whereArgs: [pkValue]);
    await load();
  }
}
