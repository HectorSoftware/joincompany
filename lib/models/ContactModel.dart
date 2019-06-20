import 'dart:convert';

class ContactModel {
  int id;
  String createdAt;
  String updatedAt;
  String deletedAt;
  int createdById;
  int updatedById;
  int deletedById;
  int customerId;
  String customer;
  String code;
  String name;
  String phone;
  String email;
  String details;

  ContactModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.createdById,
    this.updatedById,
    this.deletedById,
    this.customerId,
    this.customer,
    this.code,
    this.name,
    this.phone,
    this.email,
    this.details,
  });

  factory ContactModel.fromJson(String str) => ContactModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ContactModel.fromMap(Map<String, dynamic> json) => new ContactModel(
    id: json["id"] != null ? json["id"] : json["contact_id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    createdById: json["created_by_id"],
    updatedById: json["updated_by_id"],
    deletedById: json["deleted_by_id"],
    customerId: json["customer_id"],
    customer: json["customer"],
    code: json["code"],
    name: json["name"] != null ? json["name"] : json["contacto"],
    phone: json["phone"],
    email: json["email"],
    details: json["details"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "contact_id": id,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "created_by_id": createdById,
    "updated_by_id": updatedById,
    "deleted_by_id": deletedById,
    "customer_id": customerId,
    "customer": customer,
    "code": code,
    "name": name,
    "phone": phone,
    "email": email,
    "details": details,
  };
}