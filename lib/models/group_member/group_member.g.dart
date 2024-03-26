// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupMember _$GroupMemberFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['board_id', 'role', 'user_email'],
  );
  return GroupMember(
    userId: json['user_id'].toString(),
    boardId: json['board_id'].toString(),
    role: $enumDecode(_$RolesEnumMap, json['role']),
    email: json['user_email'] as String,
  );
}

Map<String, dynamic> _$GroupMemberToJson(GroupMember instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'board_id': instance.boardId,
      'role': _$RolesEnumMap[instance.role]!,
      'user_email': instance.email,
    };

const _$RolesEnumMap = {
  Roles.owner: 'owner',
  Roles.admin: 'admin',
  Roles.shareholder: 'shareholder',
};
