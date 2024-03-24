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
      'invited_email',
      'status',
      'token',
      'role'
    ],
  );
  return Invitation(
    invitationId: json['invitation_id'] as String,
    inviterId: json['inviter_id'] as String,
    boardId: json['board_id'] as String,
    invitedEmail: json['invited_email'] as String,
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
      'invited_email': instance.invitedEmail,
      'status': instance.status,
      'token': instance.token,
      'role': _$RolesEnumMap[instance.role]!,
    };

const _$RolesEnumMap = {
  Roles.owner: 'owner',
  Roles.admin: 'admin',
  Roles.shareholder: 'shareholder',
};
