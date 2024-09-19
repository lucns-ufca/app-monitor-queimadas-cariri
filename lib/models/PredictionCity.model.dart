import 'package:app_monitor_queimadas/models/PredictionMonthly.model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'PredictionCity.model.g.dart';

@JsonSerializable(explicitToJson: true)
class PredictionCityModel {
  int? timestamp;

  @JsonKey(name: 'date_time')
  String? dateTime;

  String? city;

  @JsonKey(name: 'prediction_total')
  int? predictionTotal;

  @JsonKey(name: 'occurred_total')
  int? occurredTotal;

  List<PredictionMonthlyModel>? months;

  PredictionCityModel({this.timestamp, this.predictionTotal, this.dateTime, this.months, this.occurredTotal});

  factory PredictionCityModel.fromJson(Map<String, dynamic> json) => _$PredictionCityModelFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionCityModelToJson(this);
}
