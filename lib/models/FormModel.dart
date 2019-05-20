import 'dart:convert';

import 'package:joincompany/models/SectionModel.dart';

class FormModel {
  int id;
  String createdAt;
  String updatedAt;
  String deletedAt;
  int createdById;
  int updatedById;
  int deletedById;
  String name;
  bool withCheckinout;
  bool active;
  List<SectionModel> sections;

  FormModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.createdById,
    this.updatedById,
    this.deletedById,
    this.name,
    this.withCheckinout,
    this.active,
    this.sections,
  });

  factory FormModel.fromJson(String str) => FormModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FormModel.fromMap(Map<String, dynamic> json) => new FormModel(
    id: json["id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    createdById: json["created_by_id"],
    updatedById: json["updated_by_id"],
    deletedById: json["deleted_by_id"],
    name: json["name"],
    withCheckinout: json["with_checkinout"],
    active: json["active"],
    sections: json["sections"] != null ? new List<SectionModel>.from(json["sections"].map((x) => SectionModel.fromMap(x))) : null,
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
    "with_checkinout": withCheckinout,
    "active": active,
    "sections": sections != null ? new List<SectionModel>.from(sections.map((x) => x.toMap())) : null,
  };
}