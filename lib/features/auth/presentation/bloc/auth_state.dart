part of 'auth_bloc.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {
  final UserEntity user;
  LoginSuccess(this.user);
}
class LoginFailure extends LoginState {
  final String message;
  LoginFailure(this.message);
}

class LogoutSuccess extends LoginState {}
class LogoutFailure extends LoginState {
  final String message;
  LogoutFailure(this.message);
}