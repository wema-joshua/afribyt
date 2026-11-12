// repositories/auth_repository.dart

import 'dart:convert';

import 'package:http/http.dart'
    as http;
import '../services/auth_service.dart';
import '../services/user_service.dart';


class AuthRepository {

  final AuthService authService =
      AuthService();

  final UserService userService =
      UserService();

  /// =========================
  /// LOGIN
  /// =========================
  Future<Map<String, dynamic>>
      login(
    String email,
    String password,
    String role,
  ) async {

    try {

      final response =
          await http.post(

        Uri.parse(
          "https://bytly-backend.onrender.com/login",
        ),

        headers: {
          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "email": email,

          "password": password,

          "role":
              role.toLowerCase(),
        }),
      );

      final data =
          jsonDecode(
        response.body,
      );

      /// =========================
      /// SUCCESS
      /// =========================
      if (response.statusCode ==
          200) {

        /// SAVE JWT TOKEN
        await authService
            .saveToken(
          data["token"],
        );

        /// SAVE USER DATA LOCALLY
        if (data["user"] != null) {

          await userService
              .saveUserData(
            data["user"],
          );
        }

        return {

          "success": true,

          "message":
              "Login successful",

          "data": data,
        };
      }

      /// =========================
      /// FAILED LOGIN
      /// =========================
      return {

        "success": false,

        "message":
            data["message"] ??
                "Login failed",
      };

    } catch (e) {

      return {

        "success": false,

        "message":
            "Something went wrong",

        "error": e.toString(),
      };
    }
  }

  /// =========================
  /// LOGOUT
  /// =========================
  Future<void> logout() async {

    await authService.logout();

    await userService.clearUser();
  }
}