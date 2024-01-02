import 'package:json_annotation/json_annotation.dart';

part "group_member.g.dart";

@JsonSerializable()
class GroupMember {
  @JsonKey(name: "user_id", includeIfNull: false)
  final int? userId;

  @JsonKey(name: "board_id", required: true)
  final String boardId;

  @JsonKey(name: "role", required: true)
  final String role; // admin/owner/shareholder roles, shareholder is custom

  GroupMember({this.userId, required this.boardId, required this.role});

  factory GroupMember.fromJson(Map<String, dynamic> json) =>
      _$GroupMemberFromJson(json);

  Map<String, dynamic> toJson() => _$GroupMemberToJson(this);
}
