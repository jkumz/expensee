import 'package:expensee/enums/roles.dart';
import 'package:json_annotation/json_annotation.dart';

part "group_member.g.dart";

@JsonSerializable()
class GroupMember {
  @JsonKey(name: "user_id", includeIfNull: false)
  final String userId;

  @JsonKey(name: "board_id", required: true)
  final String boardId;

  @JsonKey(name: "role", required: true)
  final Roles role;

  @JsonKey(name: "user_email", required: true)
  final String email;

  GroupMember(
      {required this.userId,
      required this.boardId,
      required this.role,
      required this.email});

  factory GroupMember.fromJson(Map<String, dynamic> json) =>
      _$GroupMemberFromJson(json);

  Map<String, dynamic> toJson() => _$GroupMemberToJson(this);

  // Convert a role name from the JSON into a Dart enum
  static Roles _roleFromJson(String roleName) => Roles.values.firstWhere(
        (e) => e.toString().split('.').last == roleName,
        orElse: () => throw ArgumentError('Invalid role name: $roleName'),
      );

  // Convert a Dart enum into a role name for the JSON
  static String _roleToJson(Roles role) => role.toString().split('.').last;
}
