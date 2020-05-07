
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_demo_app/models/counter_model.dart';

class CounterJsonProvider {
  String _uuid;
  File _localFile;
  File get file => _localFile;
  
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> open(String uuid) async {
    _uuid = uuid;
    final path = join(await _localPath, '$uuid.counter.json');
    _localFile = File(path);
  }

  Future<CounterModel> read() async {
    try {
      final contents = await _localFile.readAsString();
      final Map<String, dynamic> jsonMap = jsonDecode(contents) as Map<String, dynamic>;
      return CounterModel.fromJson(jsonMap);
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      // If encountering an error, return 0
      print(_uuid);
      return CounterModel(id:DateTime.now().millisecondsSinceEpoch, uuid:_uuid, counter: 0);
    }
  }

  Future<void> write(CounterModel model) async {
    final jsonMap = model.toJson();
    final jsonString = jsonEncode(jsonMap);
    await _localFile.writeAsString('$jsonString');
  }
}