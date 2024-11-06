import 'package:json_annotation/json_annotation.dart';

part 'FireOccurrence.model.g.dart';

@JsonSerializable(explicitToJson: true)
class FireOccurrenceModel {
  String? dateTime;
  double? latitude;
  double? longitude;

  FireOccurrenceModel({this.dateTime, this.latitude, this.longitude});

  factory FireOccurrenceModel.fromJson(Map<String, dynamic> json) => _$FireOccurrenceModelFromJson(json);

  Map<String, dynamic> toJson() => _$FireOccurrenceModelToJson(this);
}
