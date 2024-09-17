// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Probability.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProbabilityModel _$ProbabilityModelFromJson(Map<String, dynamic> json) =>
    ProbabilityModel(
      timestamp: (json['timestamp'] as num?)?.toInt(),
      dateTime: json['date_time'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toInt(),
      uvIndex: (json['uv_index'] as num?)?.toInt(),
      probability: (json['probability'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProbabilityModelToJson(ProbabilityModel instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'date_time': instance.dateTime,
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'uv_index': instance.uvIndex,
      'probability': instance.probability,
    };
