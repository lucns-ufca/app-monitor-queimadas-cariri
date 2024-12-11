import 'package:json_annotation/json_annotation.dart';

part 'FireAlert.model.g.dart';

@JsonSerializable(explicitToJson: true)
class FireAlertModel {
  String? id;
  @JsonKey(name: 'issuedAt')
  String? dateTime;
  @JsonKey(name: 'imgUrl')
  String? imageUrl;
  double? latitude;
  double? longitude;
  String? status;

  FireAlertModel({this.id, this.dateTime, this.imageUrl, this.latitude, this.longitude, this.status});

  factory FireAlertModel.fromJson(Map<String, dynamic> json) => _$FireAlertModelFromJson(json);

  Map<String, dynamic> toJson() => _$FireAlertModelToJson(this);
}
