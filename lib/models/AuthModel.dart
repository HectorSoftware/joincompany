import 'dart:convert';

class AuthModel {
  String accessToken;
  String tokenType;
  int expiresIn;

  AuthModel({
      this.accessToken,
      this.tokenType,
      this.expiresIn,
  });
  
  factory AuthModel.fromJson(String str) => AuthModel.fromMap(json.decode(str));
  
  String toJson() => json.encode(toMap());

  factory AuthModel.fromMap(Map<String, dynamic> json) => new AuthModel(
      accessToken: json["access_token"],
      tokenType: json["token_type"],
      expiresIn: json["expires_in"],
  );

  Map<String, dynamic> toMap() => {
      "access_token": accessToken,
      "token_type": tokenType,
      "expires_in": expiresIn,
  };
}