// To parse this JSON data, do
//
//     final directions = directionsFromJson(jsonString);

import 'dart:convert';

class DirectionModel {
  String formattedAddress;
  Geometry geometry;
  String id;
  String name;

  DirectionModel({
    this.formattedAddress,
    this.geometry,
    this.id,
    this.name,
  });

  factory DirectionModel.fromJson(String str) => DirectionModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DirectionModel.fromMap(Map<String, dynamic> json) => new DirectionModel(
    formattedAddress: json["formatted_address"],
    geometry: Geometry.fromMap(json["geometry"]),
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toMap() => {
    "formatted_address": formattedAddress,
    "geometry": geometry.toMap(),
    "id": id,
    "name": name,
  };
}

class Geometry {
  Location location;

  Geometry({
    this.location,
  });

  factory Geometry.fromJson(String str) => Geometry.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Geometry.fromMap(Map<String, dynamic> json) => new Geometry(
    location: Location.fromMap(json["location"]),
  );

  Map<String, dynamic> toMap() => {
    "location": location.toMap(),
  };
}

class Location {
  double lat;
  double lng;

  Location({
    this.lat,
    this.lng,
  });

  factory Location.fromJson(String str) => Location.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Location.fromMap(Map<String, dynamic> json) => new Location(
    lat: json["lat"].toDouble(),
    lng: json["lng"].toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "lat": lat,
    "lng": lng,
  };
}
