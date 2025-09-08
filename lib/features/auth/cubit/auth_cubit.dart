import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_voice_assistant_app/core/models/user_model.dart';
import 'package:flutter_voice_assistant_app/core/services/token_service.dart';
import 'package:flutter_voice_assistant_app/features/auth/repository/auth_local_repository.dart';
import 'package:flutter_voice_assistant_app/features/auth/repository/auth_remote_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authRemoteRepository = AuthRemoteRepository();
  final authLocalRepository = AuthLocalRepository();
  final TokenService tokenService = TokenService();
  void getUserData() async {
    try {
      emit(AuthLoading());
      final userModel = await authRemoteRepository.getUserData();
      if (userModel != null) {
        await authLocalRepository.insertUser(userModel);
        emit(AuthLoggedIn(userModel));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      print(e);
      emit(AuthInitial());
    }
  }

  void signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      await authRemoteRepository.signup(
        name: name,
        email: email,
        password: password,
      );

      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void login({required String email, required String password}) async {
    try {
      emit(AuthLoading());
      final userModel = await authRemoteRepository.login(
        email: email,
        password: password,
      );

      if (userModel == null || userModel.token.isEmpty) {
        throw Exception("Invalid user data received from the server.");
      }

      await tokenService.setToken(userModel.token);
      await authLocalRepository.insertUser(userModel);

      emit(AuthLoggedIn(userModel));
    } catch (e, stackTrace) {
      print("Login error: $e");
      print("Stack trace: $stackTrace");
      emit(AuthError(e.toString()));
    }
  }
}
