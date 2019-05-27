import 'dart:convert';

class AddressModel {
  int id;
  String createdAt;
  String updatedAt;
  String deletedAt;
  int createdById;
  int updatedById;
  int deletedById;
  int localityId;
  String address;
  String details;
  String reference;
  double latitude;
  double longitude;
  String googlePlaceId;
  String country;
  String state;
  String city;
  String contactName;
  String contactPhone;
  String contactMobile;
  String contactEmail;
  LocalityModel locality;

  AddressModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.createdById,
    this.updatedById,
    this.deletedById,
    this.localityId,
    this.address,
    this.details,
    this.reference,
    this.latitude,
    this.longitude,
    this.googlePlaceId,
    this.country,
    this.state,
    this.city,
    this.contactName,
    this.contactPhone,
    this.contactMobile,
    this.contactEmail,
    this.locality,
  });

  factory AddressModel.fromJson(String str) => AddressModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AddressModel.fromMap(Map<String, dynamic> json) => new AddressModel(
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
    "locality": locality != null ? locality.toMap() : null,
  };
}

class LocalityModel {
  int id;
  String createdAt;
  String updatedAt;
  String deletedAt;
  int createdById;
  int updatedById;
  int deletedById;
  String collection;
  String name;
  String value;

  LocalityModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.createdById,
    this.updatedById,
    this.deletedById,
    this.collection,
    this.name,
    this.value,
  });

  factory LocalityModel.fromJson(String str) => LocalityModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LocalityModel.fromMap(Map<String, dynamic> json) => new LocalityModel(
    id: json["id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    createdById: json["created_by_id"],
    updatedById: json["updated_by_id"],
    deletedById: json["deleted_by_id"],
    collection: json["collection"],
    name: json["name"],
    value: json["value"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "created_by_id": createdById,
    "updated_by_id": updatedById,
    "deleted_by_id": deletedById,
    "collection": collection,
    "name": name,
    "value": value,
  };
}