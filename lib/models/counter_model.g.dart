// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CounterModel _$CounterModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'uuid']);
  return CounterModel(
    id: json['id'] as int,
    uuid: json['uuid'] as String,
    counter: json['counter'] as int ?? 0,
  );
}

Map<String, dynamic> _$CounterModelToJson(CounterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'counter': instance.counter,
    };
