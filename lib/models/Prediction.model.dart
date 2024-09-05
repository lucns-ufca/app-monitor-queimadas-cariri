import 'package:app_monitor_queimadas/models/PredictionData.model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Prediction.model.g.dart';

@JsonSerializable(explicitToJson: true)
class Prediction {
  @JsonKey(name: 'timestamp')
  int? timestamp;

  @JsonKey(name: 'date_time')
  String? dateTime;

  @JsonKey(name: 'city')
  String? city;

  @JsonKey(name: 'prediction_total')
  int? predictionTotal;

  @JsonKey(name: 'occurred_total')
  int? occurredTotal;

  @JsonKey(name: 'months')
  List<PredictionData>? months;

  Prediction({this.timestamp, this.predictionTotal, this.dateTime, this.months, this.occurredTotal});

  factory Prediction.fromJson(Map<String, dynamic> json) => _$PredictionFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionToJson(this);
}
