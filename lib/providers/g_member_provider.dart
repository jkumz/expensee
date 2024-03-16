import 'package:expensee/models/invitation_model.dart';
import 'package:expensee/repositories/g_member_repo.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

class GroupMemberProvider extends ChangeNotifier {
  final _repo = GroupMemberRepository();

  bool isLoading = false;

  Future<void> sendInvite(String email, String boardId) async {
    await _repo.inviteMemberToBoard(boardId, email);
  }

  Future<Invitation?> getInvite(String token) async {
    return await _repo.getInvitationDetails(token);
  }

  Future<Invitation?> acceptInvite(String token) async {
    return await _repo.acceptInvite(token);
  }

  Future<Invitation?> declineInvite(String token) async {
    return await _repo.declineInvite(token);
  }

  Future<List<Invitation>> getInvites(String userEmail, String status) async {
    return await _repo.getInvites(userEmail, status);
  }
}
