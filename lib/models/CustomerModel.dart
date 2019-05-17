// To parse this JSON data, do
//
//     final customer = customerFromJson(jsonString);

import 'dart:convert';

Customer customerFromJson(String str) => Customer.fromJson(json.decode(str));

String customerToJson(Customer data) => json.encode(data.toJson());

class Customer {
  int id;
  String createdAt;
  String updatedAt;
  String deletedAt;
  int createdById;
  int updatedById;
  int deletedById;
  String name;
  String code;
  String phone;
  String email;
  String contactName;
  String details;
  PivotCustomer pivot;

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
    this.pivot,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => new Customer(
    id: json["id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    createdById: json["created_by_id"],
    updatedById: json["updated_by_id"],
    deletedById: json["deleted_by_id"],
    name: json["name"],
    code: json["code"],
    phone: json["phone"],
    email: json["email"],
    contactName: json["contact_name"],
    details: json["details"],
    pivot: json.containsKey('pivot') ? PivotCustomer.fromJson(json["pivot"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "created_by_id": createdById,
    "updated_by_id": updatedById,
    "deleted_by_id": deletedById,
    "name": name,
    "code": code,
    "phone": phone,
    "email": email,
    "contact_name": contactName,
    "details": details,
    //"pivot": pivot != null ? pivot.toJson() : null,
  };
}

class PivotCustomer {
  int userId;
  int customerId;

  PivotCustomer({
    this.userId,
    this.customerId,
  });

  factory PivotCustomer.fromJson(Map<String, dynamic> json) => new PivotCustomer(
    userId: json["user_id"],
    customerId: json["customer_id"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "customer_id": customerId,
  };
}
