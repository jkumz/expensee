import 'package:json_annotation/json_annotation.dart';

part "invitation_model.g.dart";

@JsonSerializable()
class Invitation {
  @JsonKey(name: "invitation_id", required: true)
  final String invitationId;

  @JsonKey(name: "inviter_id", required: true)
  final String inviterId;

  @JsonKey(name: "inviter_id", required: true)
  final String invitedId;

  @JsonKey(name: "board_id", required: true)
  final String boardId;

  @JsonKey(name: "invited_email", required: true)
  final String invitedEmail;

  @JsonKey(name: "status", required: true)
  final String status;

  @JsonKey(name: "token", required: true)
  final String token;

  Invitation(
      {required this.invitationId,
      required this.inviterId,
      required this.boardId,
      required this.invitedEmail,
      required this.status,
      required this.token,
      required this.invitedId});

  factory Invitation.fromJson(Map<String, dynamic> json) =>
      _$InvitationFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationToJson(this);
}
