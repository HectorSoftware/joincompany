import 'dart:convert';

class Auth {
  String accessToken;
  String tokenType;
  int expiresIn;

  Auth({
      this.accessToken,
      this.tokenType,
      this.expiresIn,
  });
  
  factory Auth.fromJson(String str) => Auth.fromMap(json.decode(str));
  
  String toJson() => json.encode(toMap());

  factory Auth.fromMap(Map<String, dynamic> json) => new Auth(
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