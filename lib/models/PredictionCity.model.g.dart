// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PredictionCity.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictionCityModel _$PredictionCityModelFromJson(Map<String, dynamic> json) =>
    PredictionCityModel(
      timestamp: (json['timestamp'] as num?)?.toInt(),
      predictionTotal: (json['predictionTotal'] as num?)?.toInt(),
      dateTime: json['dateTime'] as String?,
      months: (json['months'] as List<dynamic>?)
          ?.map(
              (e) => PredictionMonthlyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      occurredTotal: (json['occurredTotal'] as num?)?.toInt(),
    )..city = json['city'] as String?;

Map<String, dynamic> _$PredictionCityModelToJson(
        PredictionCityModel instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'dateTime': instance.dateTime,
      'city': instance.city,
      'predictionTotal': instance.predictionTotal,
      'occurredTotal': instance.occurredTotal,
      'months': instance.months?.map((e) => e.toJson()).toList(),
    };
