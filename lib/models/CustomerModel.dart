import 'dart:convert';

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
  PivotCustomerUser pivot;

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

  factory Customer.fromJson(String str) => Customer.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Customer.fromMap(Map<String, dynamic> json) => new Customer(
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
    pivot: json.containsKey('pivot') ? PivotCustomerUser.fromMap(json["pivot"]) : null,
  );
  

  Map<String, dynamic> toMap() => {
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
    "pivot": pivot != null ? pivot.toMap() : null,
  };
}

class PivotCustomerUser {
  int userId;
  int customerId;

  PivotCustomerUser({
    this.userId,
    this.customerId,
  });

  factory PivotCustomerUser.fromJson(String str) => PivotCustomerUser.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PivotCustomerUser.fromMap(Map<String, dynamic> json) => new PivotCustomerUser(
    userId: json["user_id"],
    customerId: json["customer_id"],
  );

  Map<String, dynamic> toMap() => {
    "user_id": userId,
    "customer_id": customerId,
  };
}
