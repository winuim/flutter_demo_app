import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String dbName = 'demo.db';
const String tableName = 'demo';
const String columnId = '_id';
const String columnUuid = 'uuid';
const String columnCounter = 'counter';
const String tableCreateQuery = '''
create table $tableName ( 
  $columnId integer primary key autoincrement, 
  $columnUuid text not null,
  $columnCounter integer not null)
''';

class CounterModel {
  CounterModel({this.id, this.uuid, this.counter});

  int id;
  String uuid;
  int counter;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{columnUuid: uuid, columnCounter: counter};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  CounterModel.fromMap(Map<String, dynamic> map) {
    id = map[columnId] as int;
    uuid = map[columnUuid] as String;
    counter = map[columnCounter] as int;
  }
}

class CounterProvider {
  Database _db;

  Future open() async {
    // Set the path to the database.
    final dbPath = join(await getDatabasesPath(), dbName);
    _db = await openDatabase(dbPath, version: 1,
        // When the database is first created, create a table to store tableName.
        onCreate: (Database db, int version) async {
      await db.execute(tableCreateQuery);
    });
  }

  Future<void> close() async => _db.close();

  Future<void> createTable() async => _db.execute(tableCreateQuery);

  Future<void> dropTable() async =>
      _db.execute('DROP TABLE IF EXISTS $tableName');

  Future<void> clearTable() async => _db.execute('DELETE FROM $tableName');

  Future<CounterModel> create(CounterModel model) async {
    model.id = await _db.insert(tableName, model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return model;
  }

  Future<CounterModel> read(int id) async {
    List<Map<String, dynamic>> maps = await _db.query(tableName,
        columns: [columnId, columnUuid, columnCounter],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return CounterModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(CounterModel model) async {
    return _db.update(tableName, model.toMap(),
        where: '$columnId = ?', whereArgs: [model.id]);
  }

  Future<int> delete(int id) async {
    return _db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<List<CounterModel>> all() async {
    // Query the table for all Data.
    final List<Map<String, dynamic>> maps = await _db.query(tableName);

    // Convert the List<Map<String, dynamic> into a List<CounterModel>.
    return List.generate(maps.length, (i) {
      return CounterModel(
        id: maps[i][columnId] as int,
        uuid: maps[i][columnUuid] as String,
        counter: maps[i][columnCounter] as int,
      );
    });
  }

  Future<CounterModel> getCounterModel(String uuid) async {
    CounterModel result;
    try {
      List<Map<String, dynamic>> maps = await _db.query(tableName,
          columns: [columnId, columnUuid, columnCounter],
          where: '$columnUuid = ?',
          whereArgs: [uuid]);
      if (maps.isNotEmpty) {
        result = CounterModel.fromMap(maps.first);
      } else {
        final initModel = CounterModel(uuid: uuid, counter: 0);
        result = await create(initModel);
      }
    } catch (e, statckTrace) {
      print(e);
      print(statckTrace);
    }
    return result;
  }
}
