import 'package:json_annotation/json_annotation.dart';

part 'PredictionData.model.g.dart';

@JsonSerializable(explicitToJson: true)
class PredictionData {
  int? fireOccurrences;
  int? firesPredicted;

  PredictionData({this.fireOccurrences, this.firesPredicted});

  factory PredictionData.fromJson(Map<String, dynamic> json) => _$PredictionDataFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionDataToJson(this);
}
