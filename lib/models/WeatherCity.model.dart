import 'package:json_annotation/json_annotation.dart';

part 'WeatherCity.model.g.dart';

@JsonSerializable(explicitToJson: true)
class WeatherCityModel {
  int? timestamp;
  @JsonKey(name: 'date_time')
  String? dateTime;
  String? city;
  double? temperature;
  int? humidity;
  double? precipitation;
  int? cloud;
  @JsonKey(name: 'carbon_monoxide')
  int? carbonMonoxide;
  @JsonKey(name: 'days_without_rain')
  int? daysWithoutRain;

  WeatherCityModel({this.timestamp, this.dateTime, this.city, this.temperature, this.humidity, this.precipitation, this.cloud, this.carbonMonoxide, this.daysWithoutRain});

  factory WeatherCityModel.fromJson(Map<String, dynamic> json) => _$WeatherCityModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherCityModelToJson(this);
}
