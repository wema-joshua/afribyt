// repositories/user_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class UserRepository {
  final AuthService authService =
      AuthService();

  final UserService userService =
      UserService();

  // ==============================
  // GET PROFILE (CACHE FIRST)
  // ==============================
  Future<UserModel?> getProfile()
  async {
    try {

      // CHECK LOCAL CACHE FIRST
      final localUser =
          await userService
              .getSavedUser();

      if (localUser != null) {
        return localUser;
      }

      // IF NO CACHE, FETCH ONLINE
      return await fetchProfile();

    } catch (e) {

      print(
        "GET PROFILE ERROR: $e",
      );

      return null;
    }
  }

  // ==============================
  // FETCH USER PROFILE FROM API
  // ==============================
  Future<UserModel?> fetchProfile()
  async {

    try {

      final token =
          await authService.getToken();

      if (token == null) {
        return null;
      }

      final response =
          await http.get(

        Uri.parse(
          "https://bytly-backend.onrender.com/profile",
        ),

        headers: {

          "Content-Type":
              "application/json",

          "Authorization":
              "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        final data =
            jsonDecode(
          response.body,
        );

        final user =
            UserModel.fromJson(
          data,
        );

        // SAVE TO CACHE
        await userService
            .saveUser(user);

        return user;
      }

      return null;

    } catch (e) {

      print(
        "FETCH PROFILE ERROR: $e",
      );

      return null;
    }
  }

  // ==============================
  // GET LOCAL USER ONLY
  // ==============================
  Future<UserModel?> getLocalUser()
  async {

    return await userService
        .getSavedUser();
  }

  // ==============================
  // FORCE REFRESH FROM API
  // ==============================
  Future<UserModel?> refreshProfile()
  async {

    return await fetchProfile();
  }

  // ==============================
  // UPDATE PROFILE
  // ==============================
  Future<bool> updateProfile(
    UserModel user,
  ) async {

    try {

      final token =
          await authService.getToken();

      if (token == null) {
        return false;
      }

      final response =
          await http.put(

        Uri.parse(
          "https://bytly-backend.onrender.com/profile/update",
        ),

        headers: {

          "Content-Type":
              "application/json",

          "Authorization":
              "Bearer $token",
        },

        body: jsonEncode(
          user.toJson(),
        ),
      );

      if (response.statusCode == 200) {

        // UPDATE CACHE
        await userService
            .saveUser(user);

        return true;
      }

      return false;

    } catch (e) {

      print(
        "UPDATE PROFILE ERROR: $e",
      );

      return false;
    }
  }
}