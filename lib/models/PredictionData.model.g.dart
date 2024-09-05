// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PredictionData.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictionData _$PredictionDataFromJson(Map<String, dynamic> json) =>
    PredictionData(
      fireOccurrences: (json['fireOccurrences'] as num?)?.toInt(),
      firesPredicted: (json['firesPredicted'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PredictionDataToJson(PredictionData instance) =>
    <String, dynamic>{
      'fireOccurrences': instance.fireOccurrences,
      'firesPredicted': instance.firesPredicted,
    };
