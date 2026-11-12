// models/user_model.dart

class UserModel {

  final String id;
  final String name;
  final String email;
  final String role;
  final String country;
 final String county;
  final String subcounty;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.country,
    required this.county,
    required this.subcounty,
  });

  // ==============================
  // FROM JSON
  // ==============================
  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return UserModel(

      id: json["_id"] ?? "",

      name: json["name"] ?? "",

      email: json["email"] ?? "",

      role: json["role"] ?? "",

      country: json["country"] ?? "",

      county: json["county"] ?? "",

      subcounty: json["subcounty"] ?? "",
    );
  }

  // ==============================
  // TO JSON
  // ==============================
  Map<String, dynamic> toJson() {

    return {

      "_id": id,

      "name": name,

      "email": email,

      "role": role,

      "country": country,

      "county": county,

      "subcounty": subcounty,
    };
  }
}