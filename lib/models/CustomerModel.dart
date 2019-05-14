// To parse this JSON data, do
//
//     final customer = customerFromJson(jsonString);

import 'dart:convert';

Customer customerFromJson(String str) => Customer.fromJson(json.decode(str));

String customerToJson(Customer data) => json.encode(data.toJson());

class Customer {
  int id;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;
  int createdById;
  int updatedById;
  int deletedById;
  String name;
  String code;
  String phone;
  String email;
  String contactName;
  String details;
  //Pivot pivot;

  Customer({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.createdById,
    this.updatedById,
    this.deletedById,
    this.name,
    this.code,
    this.phone,
    this.email,
    this.contactName,
    this.details,
   // this.pivot,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => new Customer(
    id: json["id"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: DateTime.parse(json["deleted_at"]),
    createdById: json["created_by_id"],
    updatedById: json["updated_by_id"],
    deletedById: json["deleted_by_id"],
    name: json["name"],
    code: json["code"],
    phone: json["phone"],
    email: json["email"],
    contactName: json["contact_name"],
    details: json["details"],
  //  pivot: Pivot.fromJson(json["pivot"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt.toIso8601String(),
    "created_by_id": createdById,
    "updated_by_id": updatedById,
    "deleted_by_id": deletedById,
    "name": name,
    "code": code,
    "phone": phone,
    "email": email,
    "contact_name": contactName,
    "details": details,
  //  "pivot": pivot.toJson(),
  };
}

class Pivot {
  int userId;
  int customerId;

  Pivot({
    this.userId,
    this.customerId,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) => new Pivot(
    userId: json["user_id"],
    customerId: json["customer_id"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "customer_id": customerId,
  };
}
