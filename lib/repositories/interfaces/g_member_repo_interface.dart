abstract class GroupMemberRepositoryInterface {
  void refreshGroupMembers(boardId);
  Future<bool> updateGroupMember(String boardId, String userId, String newRole);
  Future<bool> deleteGroupMember(String boardId, String userId);
  Future<bool> addMember(String boardId, Map<String, dynamic> json);
}
