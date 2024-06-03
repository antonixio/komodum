import 'package:sqflite/sqflite.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

abstract mixin class StreamCrudRepository<T extends DatabaseModel, TPk> {
  Future<Database> get database;
  String get pk => 'id';
  String get table;

  Future<void> insert(T data) async {
    final db = await database;
    await db.insert(table, data.toDatabase()..remove(pk));
    await load();
  }

  Future<void> update(T data, TPk pkValue) async {
    final db = await database;
    await db.update(table, data.toDatabase()..remove(pk), where: '$pk = ?', whereArgs: [pkValue]);
    await load();
  }

  Future<void> updateSpecific(Map<String, dynamic> data, TPk pkValue) async {
    final db = await database;
    await db.update(table, data, where: '$pk = ?', whereArgs: [pkValue]);
    await load();
  }

  Future<void> delete(TPk pkValue) async {
    final db = await database;
    await db.delete(table, where: '$pk = ?', whereArgs: [pkValue]);
    await load();
  }

  Future<void> load();
}
