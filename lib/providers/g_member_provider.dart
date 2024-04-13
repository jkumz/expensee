import 'package:expensee/enums/roles.dart';
import 'package:expensee/models/group_member/group_member.dart';
import 'package:expensee/models/invitation_model.dart';
import 'package:expensee/repositories/g_member_repo.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

class GroupMemberProvider extends ChangeNotifier {
  final _repo = GroupMemberRepository();

  bool isLoading = false;

  Future<void> sendInvite(String email, String boardId, Roles role) async {
    await _repo.inviteMemberToBoard(boardId, email, role);
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

  Future<bool> removeGroupMember(String boardId, String email) async {
    return await _repo.removeMemberFromBoard(boardId, email);
  }

  Future<List<GroupMember>> getGroupMembers(
      String boardId, bool isAdmin) async {
    return await _repo.getMembers(boardId, isAdmin);
  }

  Future<bool> updateRole(String boardId, String email, Roles role) async {
    return await _repo.updateRole(boardId, email, role);
  }

  Future<bool> transferOwnership(String boardId, String email) async {
    return await _repo.transferOwnership(boardId, email);
  }

  Future<String> getMemberRole(String boardId) async {
    return await _repo.getMemberRole(boardId);
  }

  Future<void> notifyUserRemoval(String boardId, String selectedEmail) async {
    await _repo.notifyAdminsOfRemovedUser(boardId, selectedEmail);
  }

  Future<void> notifyUserAdded(String boardId, String selectedEmail) async {
    await _repo.notifyAdminsOfAddedUser(boardId, selectedEmail);
  }

  Future<bool> isGroupMember(String boardId, String email) async {
    return _repo.isGroupMember(boardId, email);
  }
}
