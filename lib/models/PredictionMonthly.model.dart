import 'package:json_annotation/json_annotation.dart';

part 'PredictionMonthly.model.g.dart';

@JsonSerializable(explicitToJson: true)
class PredictionMonthlyModel {
  int? fireOccurrences;
  int? firesPredicted;

  PredictionMonthlyModel({this.fireOccurrences, this.firesPredicted});

  factory PredictionMonthlyModel.fromJson(Map<String, dynamic> json) => _$PredictionMonthlyModelFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionMonthlyModelToJson(this);
}
