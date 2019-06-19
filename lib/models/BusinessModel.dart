import 'dart:convert';

class BusinessModel {
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
  String stage;
  String date;
  String amount;

  BusinessModel({
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
    this.stage,
    this.date,
    this.amount,
  });

  factory BusinessModel.fromJson(String str) => BusinessModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BusinessModel.fromMap(Map<String, dynamic> json) => new BusinessModel(
    id: json["id"] != null ? json["id"] : json["business_id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    createdById: json["created_by_id"],
    updatedById: json["updated_by_id"],
    deletedById: json["deleted_by_id"],
    customerId: json["customer_id"],
    customer: json["customer"],
    code: json["code"],
    name: json["name"] != null ? json["name"] : json["business"],
    stage: json["stage"],
    date: json["date"],
    amount: json["amount"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "business_id": id,
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
    "stage": stage,
    "date": date,
    "amount": amount,
  };
}
