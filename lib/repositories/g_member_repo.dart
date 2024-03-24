import 'package:expensee/enums/roles.dart';
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
  Future<GroupMember> removeMemberFromBoard(
      String boardId, String removedEmail) {
    // TODO: implement removeMemberFromBoard
    throw UnimplementedError();
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
}
