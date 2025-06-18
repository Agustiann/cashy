class UserEntity {
  final String id;
  final String email;
  final DateTime? emailConfirmedAt;

  UserEntity({
    required this.id,
    required this.email,
    this.emailConfirmedAt,
  });
}
