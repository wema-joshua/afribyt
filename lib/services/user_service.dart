// services/user_service.dart

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';

class UserService {

  // ==============================
  // STORAGE
  // ==============================
  static const FlutterSecureStorage
      _storage =
          FlutterSecureStorage();

  // ==============================
  // SAVE USER DATA
  // ==============================
  Future<void> saveUserData(
    Map<String, dynamic> user,
  ) async {

    await _storage.write(

      key: "userData",

      value: jsonEncode(user),
    );
  }

  // ==============================
  // SAVE USER MODEL
  // ==============================
  Future<void> saveUser(
    UserModel user,
  ) async {

    await _storage.write(

      key: "userData",

      value: jsonEncode(
        user.toJson(),
      ),
    );
  }

  // ==============================
  // GET SAVED USER
  // ==============================
  Future<UserModel?> getSavedUser()
  async {

    final data =
        await _storage.read(
      key: "userData",
    );

    if (data == null) {
      return null;
    }

    final decoded =
        jsonDecode(data);

    return UserModel.fromJson(
      decoded,
    );
  }

  // ==============================
  // GET RAW USER DATA
  // ==============================
  Future<Map<String, dynamic>?>
      getUserData() async {

    final data =
        await _storage.read(
      key: "userData",
    );

    if (data == null) {
      return null;
    }

    return jsonDecode(data);
  }

  // ==============================
  // CLEAR USER DATA
  // ==============================
  Future<void> clearUser()
  async {

    await _storage.delete(
      key: "userData",
    );
  }
}