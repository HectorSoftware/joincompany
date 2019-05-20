import 'dart:convert';

class CustomerModel {
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
  PivotCustomerUserModel pivot;

  CustomerModel({
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

  factory CustomerModel.fromJson(String str) => CustomerModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CustomerModel.fromMap(Map<String, dynamic> json) => new CustomerModel(
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
    pivot: json['pivot'] != null ? PivotCustomerUserModel.fromMap(json["pivot"]) : null,
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

class PivotCustomerUserModel {
  int userId;
  int customerId;

  PivotCustomerUserModel({
    this.userId,
    this.customerId,
  });

  factory PivotCustomerUserModel.fromJson(String str) => PivotCustomerUserModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PivotCustomerUserModel.fromMap(Map<String, dynamic> json) => new PivotCustomerUserModel(
    userId: json["user_id"],
    customerId: json["customer_id"],
  );

  Map<String, dynamic> toMap() => {
    "user_id": userId,
    "customer_id": customerId,
  };
}
