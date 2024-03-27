enum Roles { owner, admin, shareholder }

extension RolesExtension on Roles {
  String toFormattedString() {
    switch (this) {
      case Roles.admin:
        return 'ADMIN';
      case Roles.shareholder:
        return 'SHAREHOLDER';
      case Roles.owner:
        return 'OWNER';
      default:
        return 'Unknown';
    }
  }
}
