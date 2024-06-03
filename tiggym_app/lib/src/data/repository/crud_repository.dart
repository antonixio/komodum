// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../util/database/database_helper.dart';

class DefaultCrudRepository<T extends DatabaseModel> extends CrudRepository<T, int> {
  final String _table;
  final T Function(Map<String, dynamic>) _fromMap;

  DefaultCrudRepository({required String table, required T Function(Map<String, dynamic>) fromMap})
      : _table = table,
        _fromMap = fromMap;

  @override
  String get table => _table;

  @override
  Future<Database> get database => DatabaseHelper.instance.database;
  Type get dataType => T;

  @override
  T fromMap(Map<String, dynamic> map) => _fromMap.call(map);
}

abstract mixin class CrudRepository<T extends DatabaseModel, TPk> {
  Future<Database> get database;
  String get pk => 'id';
  String get table;

  Future<int> insertTransaction(T data, Transaction transaction) async {
    return await transaction.insert(table, data.toDatabase()..remove(pk));
  }

  Future<void> deleteWhereColumnValueNotInTransaction(String column, List<dynamic> values, Transaction transaction) async {
    if (values.isNotEmpty) {
      final whereClause = values.map((e) => '?').join(',');
      await transaction.delete(table, where: '$column IN ($whereClause)', whereArgs: values);
    }
  }

  Future<void> updateTransaction(T data, Transaction transaction) async {
    await transaction.update(table, data.toDatabase()..remove(pk), where: '$pk = ?', whereArgs: [data.toDatabase()[pk]]);
  }

  Future<void> updateSpecificTransaction(Map<String, dynamic> data, TPk pkValue, Transaction transaction) async {
    await transaction.update(table, data, where: '$pk = ?', whereArgs: [pkValue]);
  }

  Future<List<T>> getDataTransaction({
    String? whereClause,
    List<dynamic>? whereArgs,
    required Transaction transaction,
    Map<String, dynamic> Function(Map<String, dynamic>)? proxyMap,
    String? orderBy,
  }) async {
    final maps = await transaction.query(table, where: whereClause, whereArgs: whereArgs, orderBy: orderBy);
    final proxyMap0 = proxyMap ?? (Map<String, dynamic> m) => m;
    return maps.map((map) => fromMap(proxyMap0.call(Map.from(map)))).toList();
  }

  Future<int> deleteTransaction({
    String? whereClause,
    List<dynamic>? whereArgs,
    required Transaction transaction,
  }) async {
    return await transaction.delete(table, where: whereClause, whereArgs: whereArgs);
  }

  T fromMap(Map<String, dynamic> map);
}
