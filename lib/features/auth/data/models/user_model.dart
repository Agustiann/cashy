import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.email,
    super.emailConfirmedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      emailConfirmedAt: json['email_confirmed_at'] != null
          ? DateTime.parse(json['email_confirmed_at'])
          : null,
    );
  }
}
