import 'dart:async';
import 'dart:io';

import 'package:flutter_demo_app/utils/counter_db_store.dart';
import 'package:flutter_demo_app/utils/counter_file_store.dart';
import 'package:flutter_demo_app/utils/counter_json_store.dart';

abstract class ICounterStoreStrategy {
  Future<int> readCounter();
  Future<void> writeCounter(int counter);
  Future<File> get file;
}

class CounterStore {
  final List<ICounterStoreStrategy> _counterStoreStrategy = [
    CounterFileStore(), CounterDbStore(), CounterJsonStore()
  ];
  int _selectedStrategyIndex = 0;

  static final CounterStore _cache = CounterStore._internal();
  factory CounterStore() {
    return _cache;
  }
  CounterStore._internal();

  int getSelected() => _selectedStrategyIndex;
  int setSelected(int value) {
    if (0 <= value && value < _counterStoreStrategy.length) {
      _selectedStrategyIndex = value;
    }
    return _selectedStrategyIndex;
  }
  Future<void> set(int value) => _counterStoreStrategy[_selectedStrategyIndex].writeCounter(value);
  Future<int> get() => _counterStoreStrategy[_selectedStrategyIndex].readCounter();
  Future<void> reset() => _counterStoreStrategy[_selectedStrategyIndex].writeCounter(0);
  Future<File> getFile() => _counterStoreStrategy[_selectedStrategyIndex].file;
}
