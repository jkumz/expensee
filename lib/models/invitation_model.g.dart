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
      'board_id',
      'invitee_email',
      'status',
      'token'
    ],
  );
  return Invitation(
    invitationId: json['invitation_id'] as String,
    inviterId: json['inviter_id'] as String,
    boardId: json['board_id'] as String,
    invitedEmail: json['invitee_email'] as String,
    status: json['status'] as String,
    token: json['token'] as String,
  );
}

Map<String, dynamic> _$InvitationToJson(Invitation instance) =>
    <String, dynamic>{
      'invitation_id': instance.invitationId,
      'inviter_id': instance.inviterId,
      'board_id': instance.boardId,
      'invitee_email': instance.invitedEmail,
      'status': instance.status,
      'token': instance.token,
    };
