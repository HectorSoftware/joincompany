import 'dart:convert';

import 'package:joincompany/models/AddressModel.dart';

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

class CustomerWithAddressModel extends AddressModel{
  int customerId;
  int addressId;
  int approved;
  String name;
  String code;

  CustomerWithAddressModel({
    int id,
    String createdAt,
    String updatedAt,
    String deletedAt,
    int createdById,
    int updatedById,
    int deletedById,
    int localityId,
    String address,
    String details,
    String reference,
    double latitude,
    double longitude,
    String googlePlaceId,
    String country,
    String state,
    String city,
    String contactName,
    String contactPhone,
    String contactMobile,
    String contactEmail,
    LocalityModel locality,
    this.customerId,
    this.addressId,
    this.approved,
    this.name,
    this.code,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    createdById: createdById,
    updatedById: updatedById,
    deletedById: deletedById,
    localityId: localityId,
    address: address,
    details: details,
    reference: reference,
    latitude: latitude,
    longitude: longitude,
    googlePlaceId: googlePlaceId,
    country: country,
    state: state,
    city: city,
    contactName: contactName,
    contactPhone: contactPhone,
    contactMobile: contactMobile,
    contactEmail: contactEmail,
    locality: locality
  );

  factory CustomerWithAddressModel.fromJson(String str) => CustomerWithAddressModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CustomerWithAddressModel.fromMap(Map<String, dynamic> json) => new CustomerWithAddressModel(
    id: json["id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    createdById: json["created_by_id"],
    updatedById: json["updated_by_id"],
    deletedById: json["deleted_by_id"],
    localityId: json["locality_id"],
    address: json["address"],
    details: json["details"],
    reference: json["reference"],
    latitude: json['latitude'] != null ? json["latitude"].toDouble() : null,
    longitude: json['longitude'] != null ? json["longitude"].toDouble() : null,
    googlePlaceId: json["google_place_id"],
    country: json["country"],
    state: json["state"],
    city: json["city"],
    contactName: json["contact_name"],
    contactPhone: json["contact_phone"],
    contactMobile: json["contact_mobile"],
    contactEmail: json["contact_email"],
    customerId: json["customer_id"],
    addressId: json["address_id"],
    approved: json["approved"],
    name: json["name"],
    code: json["code"],
    locality: json["locality"] != null ? LocalityModel.fromMap(json["locality"]) : null,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "created_by_id": createdById,
    "updated_by_id": updatedById,
    "deleted_by_id": deletedById,
    "locality_id": localityId,
    "address": address,
    "details": details,
    "reference": reference,
    "latitude": latitude,
    "longitude": longitude,
    "google_place_id": googlePlaceId,
    "country": country,
    "state": state,
    "city": city,
    "contact_name": contactName,
    "contact_phone": contactPhone,
    "contact_mobile": contactMobile,
    "contact_email": contactEmail,
    "customer_id": customerId,
    "address_id": addressId,
    "approved": approved,
    "name": name,
    "code": code,
    "locality": locality != null ? locality.toMap() : null,
  };
}
