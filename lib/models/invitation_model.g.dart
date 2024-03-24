// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invitation _$InvitationFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'invitation_id',
      'inviter_id',
      'invited_id',
      'board_id',
      'invitee_email',
      'status',
      'token',
      'role'
    ],
  );
  return Invitation(
    invitationId: json['invitation_id'].toString(),
    inviterId: json['inviter_id'].toString(),
    boardId: json['board_id'].toString(),
    invitedEmail: json['invitee_email'] as String,
    status: json['status'] as String,
    token: json['token'] as String,
    invitedId: json['invited_id'] as String,
    role: $enumDecode(_$RolesEnumMap, json['role']),
  );
}

Map<String, dynamic> _$InvitationToJson(Invitation instance) =>
    <String, dynamic>{
      'invitation_id': instance.invitationId,
      'inviter_id': instance.inviterId,
      'invited_id': instance.invitedId,
      'board_id': instance.boardId,
      'invitee_email': instance.invitedEmail,
      'status': instance.status,
      'token': instance.token,
      'role': _$RolesEnumMap[instance.role]!,
    };

const _$RolesEnumMap = {
  Roles.owner: 'owner',
  Roles.admin: 'admin',
  Roles.shareholder: 'shareholder',
};
