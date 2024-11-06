// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FireOccurrence.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FireOccurrenceModel _$FireOccurrenceModelFromJson(Map<String, dynamic> json) =>
    FireOccurrenceModel(
      dateTime: json['dateTime'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$FireOccurrenceModelToJson(
        FireOccurrenceModel instance) =>
    <String, dynamic>{
      'dateTime': instance.dateTime,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
