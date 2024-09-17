// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ProbabilityCity.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProbabilityCityModel _$ProbabilityCityModelFromJson(
        Map<String, dynamic> json) =>
    ProbabilityCityModel(
      city: json['city'] as String?,
      probabilities: (json['probabilities'] as List<dynamic>?)
          ?.map((e) => ProbabilityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProbabilityCityModelToJson(
        ProbabilityCityModel instance) =>
    <String, dynamic>{
      'city': instance.city,
      'probabilities': instance.probabilities?.map((e) => e.toJson()).toList(),
    };
