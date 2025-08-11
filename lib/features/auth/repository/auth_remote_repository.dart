import 'dart:convert';

import 'package:flutter_voice_assistant_app/core/constants/constants.dart';
import 'package:flutter_voice_assistant_app/core/models/user_model.dart';
import 'package:flutter_voice_assistant_app/core/services/token_service.dart';
import 'package:flutter_voice_assistant_app/features/auth/repository/auth_local_repository.dart';
import 'package:http/http.dart' as http;

class AuthRemoteRepository {
  final TokenService tokenService = TokenService();
  final authLocalRepository = AuthLocalRepository();
  Future<UserModel> signup({
    required String name,
    required String password,
    required String email,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/signup'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "password": password, "email": email}),
      );
      if (res.statusCode != 201) {
        throw jsonDecode(res.body)["error"];
      }
      return UserModel.fromJson(res.body);
    } catch (e) {
      // Provide better error messages for network issues
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        throw 'No internet connection. Please check your network and try again.';
      }
      throw e.toString();
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }
      return UserModel.fromJson(res.body);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      final token = await tokenService.getToken();
      if (token == null) {
        return null;
      }
      final res = await http.post(
        Uri.parse("${Constants.backendUri}/auth/tokenIsValid"),
        headers: {"Content-Type": "application/json", "x-auth-token": token},
      );
      if (res.statusCode != 200 || jsonDecode(res.body) == false) {
        return null;
      }
      final userResponse = await http.get(
        Uri.parse("${Constants.backendUri}/auth"),
        headers: {"Content-Type": "application/json", "x-auth-token": token},
      );
      if (userResponse.body != 200) {
        throw jsonDecode(userResponse.body)['error'];
      }
      return UserModel.fromJson(userResponse.body);
    } catch (e) {
      // If network request fails, try to get user from local storage
      final user = await authLocalRepository.getUser();
      if (user != null) {
        print("Using cached user data (offline mode)");
        return user;
      }
      print("No cached user found and network error: $e");
      return null; // Return null instead of throwing error
    }
  }
}
