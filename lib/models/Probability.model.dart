import 'package:json_annotation/json_annotation.dart';

part 'Probability.model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProbabilityModel {
  @JsonKey(name: 'timestamp')
  int? timestamp;
  @JsonKey(name: 'date_time')
  String? dateTime;
  @JsonKey(name: 'temperature')
  double? temperature;
  @JsonKey(name: 'humidity')
  int? humidity;
  @JsonKey(name: 'precipitation')
  double? precipitation;
  @JsonKey(name: 'uv_index')
  int? uvIndex;
  @JsonKey(name: 'probability')
  int? probability;

  ProbabilityModel({this.timestamp, this.dateTime, this.temperature, this.humidity, this.uvIndex, this.probability});

  factory ProbabilityModel.fromJson(Map<String, dynamic> json) => _$ProbabilityModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProbabilityModelToJson(this);
}
