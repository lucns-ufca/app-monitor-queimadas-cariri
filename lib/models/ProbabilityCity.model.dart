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
}
