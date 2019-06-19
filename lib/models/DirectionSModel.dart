// To parse this JSON data, do
//
//     final directionsModel = directionsModelFromJson(jsonString);

import 'dart:convert';

class DirectionsModel {
  List<Candidate> candidates;
  String status;

  DirectionsModel({
    this.candidates,
    this.status,
  });

  factory DirectionsModel.fromJson(String str) => DirectionsModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DirectionsModel.fromMap(Map<String, dynamic> json) => new DirectionsModel(
    candidates: new List<Candidate>.from(json["candidates"].map((x) => Candidate.fromMap(x))),
    status: json["status"],
  );

  Map<String, dynamic> toMap() => {
    "candidates": new List<dynamic>.from(candidates.map((x) => x.toMap())),
    "status": status,
  };
}

class Candidate {
  String formattedAddress;
  Geometry geometry;
  String id;
  String name;

  Candidate({
    this.formattedAddress,
    this.geometry,
    this.id,
    this.name,
  });

  factory Candidate.fromJson(String str) => Candidate.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Candidate.fromMap(Map<String, dynamic> json) => new Candidate(
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
  Viewport viewport;

  Geometry({
    this.location,
    this.viewport,
  });

  factory Geometry.fromJson(String str) => Geometry.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Geometry.fromMap(Map<String, dynamic> json) => new Geometry(
    location: Location.fromMap(json["location"]),
    viewport: Viewport.fromMap(json["viewport"]),
  );

  Map<String, dynamic> toMap() => {
    "location": location.toMap(),
    "viewport": viewport.toMap(),
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

class Viewport {
  Location northeast;
  Location southwest;

  Viewport({
    this.northeast,
    this.southwest,
  });

  factory Viewport.fromJson(String str) => Viewport.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Viewport.fromMap(Map<String, dynamic> json) => new Viewport(
    northeast: Location.fromMap(json["northeast"]),
    southwest: Location.fromMap(json["southwest"]),
  );

  Map<String, dynamic> toMap() => {
    "northeast": northeast.toMap(),
    "southwest": southwest.toMap(),
  };
}
