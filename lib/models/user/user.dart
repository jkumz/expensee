import 'package:json_annotation/json_annotation.dart';

part "user.g.dart"; // auto generated

@JsonSerializable()
class User {
  @JsonKey(includeIfNull: false)
  final int? id;

  @JsonKey(name: "name", required: true)
  final String name;

  @JsonKey(name: "email", required: true)
  final String email;

  User({this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
