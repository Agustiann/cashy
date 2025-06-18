part of 'auth_bloc.dart';

abstract class LoginEvent {}

class LoginButtonPressed extends LoginEvent {
  final String email;
  final String password;

  LoginButtonPressed({required this.email, required this.password});
}

class RegisterButtonPressed extends LoginEvent {
  final String name;
  final String email;
  final String password;

  RegisterButtonPressed({required this.name, required this.email, required this.password});
}

class LogoutButtonPressed extends LoginEvent {}