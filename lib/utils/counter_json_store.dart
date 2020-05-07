import 'dart:async';
import 'dart:io';

import 'package:flutter_demo_app/models/counter_json_provider.dart';
import 'package:flutter_demo_app/models/device_uuid_model.dart';
import 'package:flutter_demo_app/utils/counter_store.dart';

class CounterJsonStore implements ICounterStoreStrategy {
  CounterJsonStore() {
    _provider = CounterJsonProvider();
    _deviceUuidModel = DeviceUuidModel();
  }
  CounterJsonProvider _provider;
  DeviceUuidModel _deviceUuidModel;

  @override
  Future<File> get file => Future.value(_provider.file);

  @override
  Future<int> readCounter() async {
    // print('CounterJsonStore -> readCounter()');
    final uuid = await _deviceUuidModel.read();
    await _provider.open(uuid);

    final model = await _provider.read();
    return model.counter;
  }

  @override
  Future<void> writeCounter(int counter) async {
    // print('CounterJsonStore -> writeCounter($counter)');
    final uuid = await _deviceUuidModel.read();
    await _provider.open(uuid);

    final model = await _provider.read();
    model.counter = counter;
    await _provider.write(model);
  }
}
