import 'package:expensee/enums/roles.dart';
import 'package:expensee/models/expense_board/expense_board.dart';
import 'package:expensee/models/group_member/group_member.dart';
import 'package:expensee/models/invitation_model.dart';
import 'package:expensee/repositories/interfaces/g_member_repo_interface.dart';
import 'package:expensee/services/email_service.dart';
import 'package:expensee/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

class GroupMemberRepository implements GroupMemberRepositoryInterface {
  final _service = SupabaseService();
  final _emailService = EmailService();

  @override
  Future<bool> inviteMemberToBoard(
      String boardId, String invitedEmail, Roles role) async {
    // To send emails

    const uuid = Uuid();
    final invitationToken = uuid.v4();
    bool stored = await _service.storeSentInviteDetails(
        boardId, invitedEmail, invitationToken, role);
    if (stored) {
      await _emailService.sendInviteEmail(invitedEmail, boardId, role);
    }
    return stored;
  }

  @override
  Future<bool> changeUserRole(String boardId, String userEmail) {
    // TODO: implement changeUserRole
    throw UnimplementedError();
  }

  @override
  Future<bool> removeMemberFromBoard(String boardId, String removedEmail) {
    return _service.removeGroupMember(boardId, removedEmail);
  }

  Future<Invitation?> getInvitationDetails(String token) async {
    return await _service.getInvite(token);
  }

  Future<Invitation?> acceptInvite(String token) async {
    return await _service.acceptInvite(token);
  }

  Future<Invitation?> declineInvite(String token) async {
    return await _service.declineInvite(token);
  }

  Future<List<Invitation>> getInvites(String email, String status) async {
    return await _service.getInvitesForMember(email, status);
  }

  Future<List<GroupMember>> getMembers(String boardId, bool isAdmin) async {
    return await _service.getGroupMembers(boardId, isAdmin);
  }

  Future<bool> updateRole(String boardId, String email, Roles role) async {
    return await _service.updateGroupMemberRole(
        boardId, email, role.toString().split(".").last);
  }

  Future<bool> transferOwnership(String boardId, String email) async {
    return await _service.transferBoardOwnership(boardId, email);
  }

  Future<String> getMemberRole(String boardId) async {
    return await _service.getMemberRole(boardId);
  }

  Future<void> notifyAdminsOfRemovedUser(
      String boardId, String removedEmail) async {
    List<String> mailingList = await _service.getMemberEmails(boardId, true);
    String boardName = (await _service.getBoard(boardId) as ExpenseBoard).name;
    await _emailService.sendRemovedUserEmail(
        mailingList, removedEmail, boardName);
  }

  Future<void> notifyAdminsOfAddedUser(
      String boardId, String addedEmail) async {
    List<String> mailingList = await _service.getMemberEmails(boardId, true);
    String boardName = (await _service.getBoard(boardId) as ExpenseBoard).name;
    await _emailService.sendAddedUserEmail(mailingList, addedEmail, boardName);
  }
}
