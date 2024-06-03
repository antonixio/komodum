import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

import '../../util/database/database_helper.dart';

abstract class InitializableRepository<T> {
  Future<Database> get database => DatabaseHelper.instance.database;
  String get table;

  final dataSubject = BehaviorSubject.seeded(<T>[]);
  ValueStream<List<T>> get data => dataSubject;

  bool initialized = false;

  Future<void> initialize() async {
    if (!initialized) {
      initialized = true;
      await load();
    }
  }

  Future<void> load() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    final list = maps.map((e) => fromMap(e)).toList();
    dataSubject.add(list);
  }
  
  
  T fromMap(Map<String, dynamic> map);
}
