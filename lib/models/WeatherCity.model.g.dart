// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WeatherCity.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherCityModel _$WeatherCityModelFromJson(Map<String, dynamic> json) =>
    WeatherCityModel(
      timestamp: (json['timestamp'] as num?)?.toInt(),
      dateTime: json['dateTime'] as String?,
      city: json['city'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toInt(),
      precipitation: (json['precipitation'] as num?)?.toDouble(),
      cloud: (json['cloud'] as num?)?.toInt(),
      carbonMonoxide: (json['carbon_monoxide'] as num?)?.toInt(),
      daysWithoutRain: (json['days_without_rain'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WeatherCityModelToJson(WeatherCityModel instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'dateTime': instance.dateTime,
      'city': instance.city,
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'precipitation': instance.precipitation,
      'cloud': instance.cloud,
      'carbon_monoxide': instance.carbonMonoxide,
      'days_without_rain': instance.daysWithoutRain,
    };
