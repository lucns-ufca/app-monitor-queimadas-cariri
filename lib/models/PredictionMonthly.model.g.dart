// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PredictionMonthly.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictionMonthlyModel _$PredictionMonthlyModelFromJson(
        Map<String, dynamic> json) =>
    PredictionMonthlyModel(
      fireOccurrences: (json['fireOccurrences'] as num?)?.toInt(),
      firesPredicted: (json['firesPredicted'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PredictionMonthlyModelToJson(
        PredictionMonthlyModel instance) =>
    <String, dynamic>{
      'fireOccurrences': instance.fireOccurrences,
      'firesPredicted': instance.firesPredicted,
    };
