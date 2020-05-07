import 'package:json_annotation/json_annotation.dart';

import 'package:flutter_demo_app/models/counter_db_provider.dart';

part 'counter_model.g.dart';

@JsonSerializable()
class CounterModel {
  CounterModel({this.id, this.uuid, this.counter});

  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  String uuid;

  @JsonKey(defaultValue: 0)
  int counter;

  factory CounterModel.fromJson(Map<String, dynamic> json) => _$CounterModelFromJson(json);

  Map<String, dynamic> toJson() => _$CounterModelToJson(this);

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
