// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PredictionCity.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictionCityModel _$PredictionCityModelFromJson(Map<String, dynamic> json) =>
    PredictionCityModel(
      id: json['id'] as String?,
      predictionTotal: (json['predictionTotal'] as num?)?.toInt(),
      dateTime: json['createdAt'] as String?,
      months: (json['monthData'] as List<dynamic>?)
          ?.map(
              (e) => PredictionMonthlyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      occurredTotal: (json['occurredTotal'] as num?)?.toInt(),
    )..city = json['city'] as String?;

Map<String, dynamic> _$PredictionCityModelToJson(
        PredictionCityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.dateTime,
      'city': instance.city,
      'predictionTotal': instance.predictionTotal,
      'occurredTotal': instance.occurredTotal,
      'monthData': instance.months?.map((e) => e.toJson()).toList(),
    };
