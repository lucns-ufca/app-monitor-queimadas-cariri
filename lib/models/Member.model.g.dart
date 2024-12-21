// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Member.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberModel _$MemberModelFromJson(Map<String, dynamic> json) => MemberModel(
      name: json['name'] as String?,
      description: json['description'] as String?,
      technologies: json['technologies'] as String?,
      lattes: json['lattes'] as String?,
      email: json['email'] as String?,
      orcid: json['orcid'] as String?,
      github: json['github'] as String?,
      linkedin: json['linkedin'] as String?,
      instagram: json['instagram'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$MemberModelToJson(MemberModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'technologies': instance.technologies,
      'email': instance.email,
      'linkedin': instance.linkedin,
      'lattes': instance.lattes,
      'orcid': instance.orcid,
      'github': instance.github,
      'instagram': instance.instagram,
      'image': instance.image,
    };
