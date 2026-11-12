// services/auth_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {

  // ==============================
  // SECURE STORAGE
  // ==============================
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  // ==============================
  // TOKEN STORAGE
  // ==============================
  Future<void> saveToken(
    String token,
  ) async {

    await _storage.write(
      key: 'jwtToken',
      value: token,
    );
  }

  Future<String?> getToken() async {

    return await _storage.read(
      key: 'jwtToken',
    );
  }

  // ==============================
  // CHECK LOGIN STATUS
  // ==============================
  Future<bool> isLoggedIn() async {

    final token = await getToken();

    if (token == null ||
        token.isEmpty) {

      return false;
    }

    final expired =
        JwtDecoder.isExpired(
      token,
    );

    if (expired) {

      await logout();

      return false;
    }

    return true;
  }

  // ==============================
  // DECODE TOKEN
  // ==============================
  Map<String, dynamic>? decodeToken(
    String token,
  ) {

    try {

      return JwtDecoder.decode(
        token,
      );

    } catch (e) {

      return null;
    }
  }

  // ==============================
  // GET ROLE FROM TOKEN
  // ==============================
  Future<String?> getUserRole()
  async {

    final token =
        await getToken();

    if (token == null) {
      return null;
    }

    final decoded =
        JwtDecoder.decode(
      token,
    );

    return decoded["role"];
  }

  // ==============================
  // LOGOUT
  // ==============================
  Future<void> logout() async {

    await _storage.delete(
      key: 'jwtToken',
    );
  }

  // ==============================
  // CLEAR EVERYTHING
  // ==============================
  Future<void> clearStorage()
  async {

    await _storage.deleteAll();
  }
}