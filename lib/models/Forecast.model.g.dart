// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Forecast.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastModel _$ForecastModelFromJson(Map<String, dynamic> json) =>
    ForecastModel(
      timestamp: (json['timestamp'] as num?)?.toInt(),
      dateTime: json['dateTime'] as String?,
      city: json['city'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toInt(),
      uvIndex: (json['uvIndex'] as num?)?.toInt(),
      precipitation: (json['precipitation'] as num?)?.toDouble(),
      cloud: (json['cloud'] as num?)?.toInt(),
      carbonMonoxide: (json['carbonMonoxide'] as num?)?.toInt(),
      daysWithoutRain: (json['daysWithoutRain'] as num?)?.toInt(),
      fireRisk: (json['fireRisk'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ForecastModelToJson(ForecastModel instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'dateTime': instance.dateTime,
      'city': instance.city,
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'uvIndex': instance.uvIndex,
      'precipitation': instance.precipitation,
      'cloud': instance.cloud,
      'carbonMonoxide': instance.carbonMonoxide,
      'daysWithoutRain': instance.daysWithoutRain,
      'fireRisk': instance.fireRisk,
    };
