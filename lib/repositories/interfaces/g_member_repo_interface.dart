import 'package:expensee/enums/roles.dart';

abstract class GroupMemberRepositoryInterface {
  Future<void> inviteMemberToBoard(
      String boardId, String invitedEmail, Roles role);
  Future<bool> removeMemberFromBoard(String boardId, String removedEmail);
  Future<bool> updateRole(String boardId, String email, Roles role);
}
