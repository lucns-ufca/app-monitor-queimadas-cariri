// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PredictionCity.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictionCityModel _$PredictionCityModelFromJson(Map<String, dynamic> json) =>
    PredictionCityModel(
      timestamp: (json['timestamp'] as num?)?.toInt(),
      predictionTotal: (json['prediction_total'] as num?)?.toInt(),
      dateTime: json['date_time'] as String?,
      months: (json['months'] as List<dynamic>?)
          ?.map(
              (e) => PredictionMonthlyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      occurredTotal: (json['occurred_total'] as num?)?.toInt(),
    )..city = json['city'] as String?;

Map<String, dynamic> _$PredictionCityModelToJson(
        PredictionCityModel instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'date_time': instance.dateTime,
      'city': instance.city,
      'prediction_total': instance.predictionTotal,
      'occurred_total': instance.occurredTotal,
      'months': instance.months?.map((e) => e.toJson()).toList(),
    };
