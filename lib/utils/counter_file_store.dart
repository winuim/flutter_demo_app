import 'dart:async';
import 'dart:io';

import 'package:flutter_demo_app/models/device_uuid_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_demo_app/utils/counter_store.dart';

class CounterFileStore implements ICounterStoreStrategy {
  CounterFileStore() {
    _deviceUuidModel = DeviceUuidModel();
  }
  DeviceUuidModel _deviceUuidModel;

  @override
  Future<File> get file => _localFile;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final uuid = await _deviceUuidModel.read();
    final path = join(await _localPath, '$uuid.counter.txt');
    return File(path);
  }

  @override
  Future<int> readCounter() async {
    // print('CounterFileStore -> readCounter()');
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return int.parse(contents);
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      // If encountering an error, return 0
      return 0;
    }
  }

  @override
  Future<void> writeCounter(int counter) async {
    // print('CounterFileStore -> writeCounter($counter)');
    final file = await _localFile;
    await file.writeAsString('$counter');
  }
}
