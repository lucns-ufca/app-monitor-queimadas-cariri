import 'package:monitor_queimadas_cariri/models/Forecast.model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ForecastCity.model.g.dart';

@JsonSerializable(explicitToJson: true)
class ForecastCityModel {
  String? city;
  List<ForecastModel>? forecast;

  ForecastCityModel({this.city, this.forecast});

  factory ForecastCityModel.fromJson(Map<String, dynamic> json) => _$ForecastCityModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastCityModelToJson(this);

  int getMaximumFireRisk() {
    int value = 0;
    for (ForecastModel model in forecast!) {
      if (model.fireRisk! > value) value = model.fireRisk!;
    }
    return 0;
  }

  int getMaximumUvIndex() {
    int value = 0;
    for (ForecastModel model in forecast!) {
      if (model.uvIndex! > value) value = model.uvIndex!;
    }
    return 0;
  }

  int getMaximumTemperature() {
    double value = 0;
    for (ForecastModel model in forecast!) {
      if (model.temperature! > value) value = model.temperature!;
    }
    return 0;
  }

  double getMaximumPrecipitation() {
    double value = 0;
    for (ForecastModel model in forecast!) {
      if (model.precipitation! > value) value = model.precipitation!;
    }
    return 0;
  }
}
