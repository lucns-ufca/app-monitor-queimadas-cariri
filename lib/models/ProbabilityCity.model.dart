import 'package:app_monitor_queimadas/models/Probability.model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ProbabilityCity.model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProbabilityCityModel {
  String? city;
  List<ProbabilityModel>? probabilities;

  ProbabilityCityModel({this.city, this.probabilities});

  factory ProbabilityCityModel.fromJson(Map<String, dynamic> json) => _$ProbabilityCityModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProbabilityCityModelToJson(this);

  int getMaximumProbability() {
    int value = 0;
    for (ProbabilityModel model in probabilities!) {
      if (model.probability! > value) value = model.probability!;
    }
    return 0;
  }

  int getMaximumUvIndex() {
    int value = 0;
    for (ProbabilityModel model in probabilities!) {
      if (model.uvIndex! > value) value = model.uvIndex!;
    }
    return 0;
  }

  int getMaximumTemperature() {
    int value = 0;
    for (ProbabilityModel model in probabilities!) {
      if (model.probability! > value) value = model.probability!;
    }
    return 0;
  }

  double getMaximumPrecipitation() {
    double value = 0;
    for (ProbabilityModel model in probabilities!) {
      if (model.precipitation! > value) value = model.precipitation!;
    }
    return 0;
  }
}
