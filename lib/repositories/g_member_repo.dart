import 'package:expensee/repositories/interfaces/g_member_repo_interface.dart';
import 'package:expensee/services/supabase_service.dart';

class GroupMemberRepository implements GroupMemberRepositoryInterface {
  final _service = SupabaseService();

  @override
  Future<void> refreshGroupMembers(boardId) async {
    //
  }

  @override
  Future<bool> addMember(String boardId, Map<String, dynamic> json) async {
    final _added = _service.addMemberToBoard(boardId, json);

    return _added;
  }

  @override
  Future<bool> deleteGroupMember(String boardId, String userId) async {
    final _deleted = _service.deleteGroupMember(boardId, userId);

    return _deleted;
  }

  @override
  Future<bool> updateGroupMember(
      String boardId, String userId, String newRole) {
    final _updated = _service.updateGroupMemberRole(boardId, userId, newRole);

    return _updated;
  }
}
