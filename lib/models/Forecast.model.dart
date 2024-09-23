import 'package:json_annotation/json_annotation.dart';

part 'Forecast.model.g.dart';

@JsonSerializable(explicitToJson: true)
class ForecastModel {
  //@JsonKey(name: 'timestamp')
  int? timestamp;
  String? dateTime;
  String? city;
  double? temperature;
  int? humidity;
  int? uvIndex;
  double? precipitation;
  int? cloud;
  int? carbonMonoxide;
  int? daysWithoutRain;
  int? fireRisk;

  ForecastModel({this.timestamp, this.dateTime, this.city, this.temperature, this.humidity, this.uvIndex, this.precipitation, this.cloud, this.carbonMonoxide, this.daysWithoutRain, this.fireRisk});

  factory ForecastModel.fromJson(Map<String, dynamic> json) => _$ForecastModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastModelToJson(this);
}
