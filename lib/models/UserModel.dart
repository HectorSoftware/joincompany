import 'dart:convert';

class UserModel {
  int id;
  String createdAt;
  String updatedAt;
  String deletedAt;
  int createdById;
  int updatedById;
  int deletedById;
  int supervisorId;
  String name;
  String code;
  String email;
  String phone;
  String mobile;
  String title;
  String details;
  String profile;
  String password;
  String remenberToken;
  String loggedAt;

  UserModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.createdById,
    this.updatedById,
    this.deletedById,
    this.supervisorId,
    this.name,
    this.code,
    this.email,
    this.phone,
    this.mobile,
    this.title,
    this.details,
    this.profile,
    this.password,
    this.remenberToken,
    this.loggedAt,
  });

  factory UserModel.fromJson(String str) => UserModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserModel.fromMap(Map<String, dynamic> json) => new UserModel(
    id: json["id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    createdById: json["created_by_id"],
    updatedById: json["updated_by_id"],
    deletedById: json["deleted_by_id"],
    supervisorId: json["supervisor_id"],
    name: json["name"],
    code: json["code"],
    email: json["email"],
    phone: json["phone"],
    mobile: json["mobile"],
    title: json["title"],
    details: json["details"],
    profile: json["profile"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "created_by_id": createdById,
    "updated_by_id": updatedById,
    "deleted_by_id": deletedById,
    "supervisor_id": supervisorId,
    "name": name,
    "code": code,
    "email": email,
    "phone": phone,
    "mobile": mobile,
    "title": title,
    "details": details,
    "profile": profile,
  };
}
