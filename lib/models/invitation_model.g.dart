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
    invitationId: json['invitation_id'].toString(),
    inviterId: json['inviter_id'].toString(),
    boardId: json['board_id'].toString(),
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
