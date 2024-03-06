import 'package:expensee/models/group_member/group_member.dart';

abstract class GroupMemberRepositoryInterface {
  Future<void> inviteMemberToBoard(String boardId, String invitedEmail);
  Future<GroupMember> removeMemberFromBoard(
      String boardId, String removedEmail);
  Future<bool> changeUserRole(String boardId, String userEmail);
}
