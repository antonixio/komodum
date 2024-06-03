import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "konta.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    Database? db = _database;
    if (db != null) return db;
    // instancia o db na primeira vez que for acessado
    db = await _initDatabase();
    _database = db;
    return db;
  }

  Future<String> getDbPath() async {
    return join(await _dbPath(), _databaseName);
  }

  Future<String> _dbPath() async {
    return getDatabasesPath();
  }

  Future<void> initialize() async => _initDatabase();

  // abre o banco de dados e o cria se ele não existir
  Future<Database> _initDatabase() async {
    return await openDatabase(
      await getDbPath(),
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final creationMap = {
      1: _onCreateV1,
    };

    await creationMap[version]?.call(db);
  }

  Future<void> _onCreateV1(Database db) async {
    try {
      final script = await rootBundle.loadString('assets/database/v1/script.sql');

      final scripts = script.split("/* BREAK */").where((q) => q.trim().isNotEmpty).map((e) => e.trim());
      // ignore: avoid_function_literals_in_foreach_calls
      scripts.forEach((query) async {
        await db.execute(query);
      });
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<void> _onConfigure(Database db) async {
    // final script = await rootBundle.loadString('assets/database/v1/clear.sql');

    // script.split("/* BREAK */").where((q) => q.trim().isNotEmpty).forEach((query) async {
    //   await db.execute(query);
    // });

    await _onCreate(db, 1);
  }

  Future<File> getDatabaseFile() async {
    return File(await getDbPath());
  }
}
