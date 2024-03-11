// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupMember _$GroupMemberFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['board_id', 'role_id'],
  );
  return GroupMember(
    userId: json['user_id'] as int?,
    boardId: json['board_id'] as String,
    role: json['role_id'] as String,
  );
}

Map<String, dynamic> _$GroupMemberToJson(GroupMember instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('user_id', instance.userId);
  val['board_id'] = instance.boardId;
  val['role_id'] = instance.role;
  return val;
}
