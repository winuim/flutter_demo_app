import 'dart:async';
import 'dart:io';

import 'package:flutter_demo_app/models/counter_db_provider.dart';
import 'package:flutter_demo_app/models/device_uuid_model.dart';
import 'package:flutter_demo_app/utils/counter_store.dart';

class CounterDbStore implements ICounterStoreStrategy {
  CounterDbStore() {
    _provider = CounterDbProvider();
    _deviceUuidModel = DeviceUuidModel();
  }
  CounterDbProvider _provider;
  DeviceUuidModel _deviceUuidModel;

  @override
  Future<int> readCounter() async {
    // print('CounterDbStore -> readCounter()');
    int result;
    await _provider.open();
    final uuid = await _deviceUuidModel.read();

    await _provider.getCounterModel(uuid).then((value) {
      result = value.counter;
    }).whenComplete(() {
      // print('CounterDbStore -> close()');
      _provider.close();
    });

    return result;
  }

  @override
  Future<void> writeCounter(int counter) async {
    // print('CounterDbStore -> writeCounter($counter)');
    await _provider.open();
    final uuid = await _deviceUuidModel.read();

    await _provider.getCounterModel(uuid).then((model) {
      model.counter = counter;
      _provider.update(model);
    }).whenComplete(() {
      // print('CounterDbStore -> close()');
      _provider.close();
    });
  }

  @override
  Future<File> get file => _provider.file;
}
