import 'package:expensee/models/group_member/group_member.dart';
import 'package:expensee/repositories/interfaces/g_member_repo_interface.dart';
import 'package:expensee/services/email_service.dart';
import 'package:expensee/services/supabase_service.dart';

class GroupMemberRepository implements GroupMemberRepositoryInterface {
  final _service = SupabaseService();
  final _emailService = EmailService();

  @override
  Future<void> inviteMemberToBoard(String boardId, String invitedEmail) async {
    // To send emails
    await _emailService.sendInvite(invitedEmail, boardId);
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
}
