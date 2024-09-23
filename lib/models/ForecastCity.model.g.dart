// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ForecastCity.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastCityModel _$ForecastCityModelFromJson(Map<String, dynamic> json) =>
    ForecastCityModel(
      city: json['city'] as String?,
      forecast: (json['forecast'] as List<dynamic>?)
          ?.map((e) => ForecastModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ForecastCityModelToJson(ForecastCityModel instance) =>
    <String, dynamic>{
      'city': instance.city,
      'forecast': instance.forecast?.map((e) => e.toJson()).toList(),
    };
