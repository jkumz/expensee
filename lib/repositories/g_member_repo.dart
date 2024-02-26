import 'package:expensee/models/group_member/group_member.dart';
import 'package:expensee/repositories/interfaces/g_member_repo_interface.dart';
import 'package:expensee/services/supabase_service.dart';

class GroupMemberRepository implements GroupMemberRepositoryInterface {
  final _service = SupabaseService();

  @override
  Future<bool> addMemberToBoard(String boardId, String invitedEmail) {
    // TODO: implement addMemberToBoard
    throw UnimplementedError();
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
