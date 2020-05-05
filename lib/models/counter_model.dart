import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String dbName = 'demo.db';
const String tableName = 'demo';
const String columnId = '_id';
const String columnUid = 'uid';
const String columnCounter = 'counter';

class CounterModel {
  CounterModel({this.id, this.uid, this.counter});

  int id;
  String uid;
  int counter;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{columnUid: uid, columnCounter: counter};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  CounterModel.fromMap(Map<String, dynamic> map) {
    id = map[columnId] as int;
    uid = map[columnUid] as String;
    counter = map[columnCounter] as int;
  }
}

class CounterProvider {
  Database _db;
  Database get db => _db;

  Future<void> open() async {
    _db = await openDatabase(
      // Set the path to the database.
      join(await getDatabasesPath(), dbName),
      // When the database is first created, create a table to store tableName.
      onCreate: (Database db, int version) async {
        await db.execute('''
create table $tableName ( 
  $columnId integer primary key autoincrement, 
  $columnUid text not null,
  $columnCounter integer not null)
''');
      },
      version: 1,
    );
  }

  Future<List<CounterModel>> all() async {
    // Query the table for all Data.
    final List<Map<String, dynamic>> maps = await _db.query(tableName);

    // Convert the List<Map<String, dynamic> into a List<CounterModel>.
    return List.generate(maps.length, (i) {
      return CounterModel(
        id: maps[i][columnId] as int,
        uid: maps[i][columnUid] as String,
        counter: maps[i][columnCounter] as int,
      );
    });
  }

  Future<CounterModel> getModel(int id) async {
    List<Map<String, dynamic>> maps = await _db.query(tableName,
        columns: [columnId, columnUid, columnCounter],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return CounterModel.fromMap(maps.first);
    }
    return null;
  }

  Future<CounterModel> insert(CounterModel model) async {
    model.id = await _db.insert(tableName, model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return model;
  }

  Future<int> delete(int id) async {
    return _db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(CounterModel model) async {
    return _db.update(tableName, model.toMap(),
        where: '$columnId = ?', whereArgs: [model.id]);
  }

  Future<void> close() async => _db.close();

  Future<CounterModel> getUidModel(String uid) async {
    List<Map<String, dynamic>> maps = await _db.query(tableName,
        columns: [columnId, columnUid, columnCounter],
        where: '$columnUid = ?',
        whereArgs: [uid]);
    if (maps.isNotEmpty) {
      return CounterModel.fromMap(maps.first);
    } else {
      final model = CounterModel(uid: uid, counter: 0);
      return insert(model);
    }
  }
}
