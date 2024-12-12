// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FireAlert.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FireAlertModel _$FireAlertModelFromJson(Map<String, dynamic> json) =>
    FireAlertModel(
      id: json['id'] as String?,
      dateTime: json['issuedAt'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imgUrl'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$FireAlertModelToJson(FireAlertModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'issuedAt': instance.dateTime,
      'imgUrl': instance.imageUrl,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'status': instance.status,
      'description': instance.description,
    };
