import 'package:json_annotation/json_annotation.dart';

part 'Member.model.g.dart';

@JsonSerializable(explicitToJson: true)
class MemberModel {
  String? name, description, technologies, email, linkedin, lattes, orcid, github, instagram, image;
  MemberModel({this.name, this.description, this.technologies, this.lattes, this.email, this.orcid, this.github, this.linkedin, this.instagram, this.image});

  factory MemberModel.fromJson(Map<String, dynamic> json) => _$MemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$MemberModelToJson(this);
}
