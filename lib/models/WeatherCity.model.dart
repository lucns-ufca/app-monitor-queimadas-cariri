import 'package:json_annotation/json_annotation.dart';

part 'WeatherCity.model.g.dart';

@JsonSerializable(explicitToJson: true)
class WeatherCityModel {
  @JsonKey(name: 'timestamp')
  int? timestamp;
  @JsonKey(name: 'dateTime')
  String? dateTime;
  @JsonKey(name: 'city')
  String? city;
  @JsonKey(name: 'temperature')
  double? temperature;
  @JsonKey(name: 'humidity')
  int? humidity;
  @JsonKey(name: 'precipitation')
  double? precipitation;
  @JsonKey(name: 'cloud')
  int? cloud;
  @JsonKey(name: 'carbon_monoxide')
  int? carbonMonoxide;
  @JsonKey(name: 'days_without_rain')
  int? daysWithoutRain;

  WeatherCityModel({this.timestamp, this.dateTime, this.city, this.temperature, this.humidity, this.precipitation, this.cloud, this.carbonMonoxide, this.daysWithoutRain});

  factory WeatherCityModel.fromJson(Map<String, dynamic> json) => _$WeatherCityModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherCityModelToJson(this);
}
