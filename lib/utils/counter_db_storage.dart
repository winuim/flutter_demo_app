import 'dart:async';

import '../models/counter_model.dart';
import 'counter_store.dart';
import 'sharedpref_device_uuid.dart';

class CounterDbStorage implements ICounterStoreStrategy {
  CounterDbStorage() {
    _provider = CounterProvider();
    _sharedprefDeviceUUID = SharedprefDeviceUUID();
  }
  CounterProvider _provider;
  SharedprefDeviceUUID _sharedprefDeviceUUID;

  @override
  Future<int> readCounter() async {
    // print('CounterDbStorage -> readCounter()');
    int result;
    await _provider.open();

    final uuid = await _sharedprefDeviceUUID.read();
    await _provider.getCounterModel(uuid).then((value) {
      result = value.counter;
    }).whenComplete(() {
      // print('CounterDbStorage -> close()');
      _provider.close();
    });

    return result;
  }

  @override
  Future<void> writeCounter(int counter) async {
    // print('CounterDbStorage -> writeCounter($counter)');
    await _provider.open();

    final uuid = await _sharedprefDeviceUUID.read();
    await _provider.getCounterModel(uuid).then((model) {
      model.counter = counter;
      _provider.update(model);
    }).whenComplete(() {
      // print('CounterDbStorage -> close()');
      _provider.close();
    });
  }
}
