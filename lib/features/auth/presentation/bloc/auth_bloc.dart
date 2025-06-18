import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/auth_usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/datasources/auth_remote_datasource.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class EmailVerificationRequired extends LoginState {
  final String message;
  EmailVerificationRequired(this.message);
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;
  final AuthRemoteDataSource remoteDataSource; // Menambahkan dependency

  LoginBloc({required this.loginUseCase, required this.remoteDataSource}) : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        final user = await loginUseCase.call(event.email, event.password);
        if (user.emailConfirmedAt == null) {
          emit(LoginFailure("Akun belum diverifikasi. Silakan cek email Anda."));
        } else {
          emit(LoginSuccess(user));
        }
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });

    on<RegisterButtonPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        await loginUseCase.repository
            .register(event.name, event.email, event.password);
        emit(EmailVerificationRequired(
            'Akun berhasil dibuat. Silakan cek email untuk verifikasi.'));
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });

    // Menangani event logout
    on<LogoutButtonPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        await remoteDataSource.logout(); // Menanggapi logout
        emit(LogoutSuccess()); // Berhasil logout
      } catch (e) {
        emit(LogoutFailure(e.toString()));
      }
    });
  }
}


