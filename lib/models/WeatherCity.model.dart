import 'package:json_annotation/json_annotation.dart';

part 'WeatherCity.model.g.dart';

@JsonSerializable(explicitToJson: true)
class WeatherCityModel {
  //@JsonKey(name: 'dateTime')
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

  WeatherCityModel({this.timestamp, this.dateTime, this.city, this.temperature, this.humidity, this.uvIndex, this.precipitation, this.cloud, this.carbonMonoxide, this.daysWithoutRain, this.fireRisk});

  factory WeatherCityModel.fromJson(Map<String, dynamic> json) => _$WeatherCityModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherCityModelToJson(this);
}
