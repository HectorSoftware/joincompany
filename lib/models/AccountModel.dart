import 'dart:convert';

class Account {
  String time;
  CustomerAccount customer;

  Account({
      this.time,
      this.customer,
  });

  factory Account.fromJson(String str) => Account.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Account.fromMap(Map<String, dynamic> json) => new Account(
      time: json["time"],
      customer: json['customer'] != null ? CustomerAccount.fromMap(json["customer"]) : null,
  );

  Map<String, dynamic> toMap() => {
      "time": time,
      "customer": customer != null ? customer.toMap() : null,
  };
}

class CustomerAccount {
  int id;
  String createdAt;
  String updatedAt;
  String deletedAt;
  String name;
  String timezone;
  bool associateDirections;
  double initialLatitude;
  double initialLongitude;
  bool customersByUsers;
  String country;
  String countryCode;
  String receiverEmail;
  String receiverName;

  CustomerAccount({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.name,
    this.timezone,
    this.associateDirections,
    this.initialLatitude,
    this.initialLongitude,
    this.customersByUsers,
    this.country,
    this.countryCode,
    this.receiverEmail,
    this.receiverName,
  });

  factory CustomerAccount.fromJson(String str) => CustomerAccount.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CustomerAccount.fromMap(Map<String, dynamic> json) => new CustomerAccount(
    id: json["id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    name: json["name"],
    timezone: json["timezone"],
    associateDirections: json["associate_directions"],
    initialLatitude: json["initial_latitude"] != null ? json["initial_latitude"].toDouble() : null,
    initialLongitude: json["initial_longitude"] != null ? json["initial_longitude"].toDouble() : null,
    customersByUsers: json["customers_by_users"],
    country: json["country"],
    countryCode: json["country_code"],
    receiverEmail: json["receiver_email"],
    receiverName: json["receiver_name"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "name": name,
    "timezone": timezone,
    "associate_directions": associateDirections,
    "initial_latitude": initialLatitude,
    "initial_longitude": initialLongitude,
    "customers_by_users": customersByUsers,
    "country": country,
    "country_code": countryCode,
    "receiver_email": receiverEmail,
    "receiver_name": receiverName,
  };
}