import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'dart:math';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  String translateError(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('invalid login credentials')) {
      return 'Email atau kata sandi salah.';
    }  else if (lowerError.contains('user already registered')) {
      return 'Email sudah terdaftar.';
    } else if (lowerError.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi.';
    } else if (lowerError.contains('missing email or phone')) {
      return 'Email dan kata sandi harus diisi.';
    } else if (lowerError.contains('anonymous sign-ins are disabled')) {
      return 'Isi semua data.';
    } else {
      return error;
    }
  }

  final SupabaseClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        return UserModel(
          id: user.id,
          email: user.email!,
          emailConfirmedAt: user.emailConfirmedAt != null
              ? DateTime.parse(user.emailConfirmedAt!)
              : null,
        );
      } else {
        throw 'Gagal masuk';
      }
    } on AuthApiException catch (e) {
      throw translateError(e.message);
    }
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    try {
      final randomColor = _generateRandomColorHex();

      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': name,
          'avatar_color': randomColor,
        },
      );

      final user = response.user;

      if (user != null) {
        await client.from('categories').insert([
          {
            'id': const Uuid().v4(),
            'user_id': user.id,
            'name': 'Bayar Kos',
            'type': 'expense',
          },
          {
            'id': const Uuid().v4(),
            'user_id': user.id,
            'name': 'Biaya Kuliah',
            'type': 'expense',
          },
        ]);
        return UserModel(
          id: user.id,
          email: user.email!,
          emailConfirmedAt: user.emailConfirmedAt != null
              ? DateTime.parse(user.emailConfirmedAt!)
              : null,
        );
      } else {
        throw 'Gagal daftar';
      }
    } on AuthApiException catch (e) {
      throw translateError(e.message);
    }
  }

  String _generateRandomColorHex() {
    final random = Random();
    final r = random.nextInt(256);
    final g = random.nextInt(256);
    final b = random.nextInt(256);
    final a = 255;

    return '#${(a << 24 | r << 16 | g << 8 | b).toRadixString(16).padLeft(8, '0')}';
  }

  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } on AuthApiException catch (e) {
      throw translateError(e.message);
    }
  }
}
