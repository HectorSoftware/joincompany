import 'dart:convert';

import 'package:joincompany/models/FieldModel.dart';

class Section {
  int id;
  String createdAt;
  String updatedAt;
  String deletedAt;
  int createdById;
  int updatedById;
  int deletedById;
  int sectionId;
  String entityType;
  int entityId;
  String type;
  String name;
  String code;
  String subtitle;
  int position;
  String fieldDefaultValue;
  String fieldType;
  String fieldPlaceholder;
  List<FieldOption> fieldOptions;
  String fieldCollection;
  bool fieldRequired;
  int fieldWidth;
  List<Field> fields;

  Section({
      this.id,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.createdById,
      this.updatedById,
      this.deletedById,
      this.sectionId,
      this.entityType,
      this.entityId,
      this.type,
      this.name,
      this.code,
      this.subtitle,
      this.position,
      this.fieldDefaultValue,
      this.fieldType,
      this.fieldPlaceholder,
      this.fieldOptions,
      this.fieldCollection,
      this.fieldRequired,
      this.fieldWidth,
      this.fields,
  });

  factory Section.fromJson(String str) => Section.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Section.fromMap(Map<String, dynamic> json) => new Section(
    id: json["id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    createdById: json["created_by_id"],
    updatedById: json["updated_by_id"],
    deletedById: json["deleted_by_id"],
    sectionId: json["section_id"],
    entityType: json["entity_type"],
    entityId: json["entity_id"],
    type: json["type"],
    name: json["name"],
    code: json["code"],
    subtitle: json["subtitle"],
    position: json["position"],
    fieldDefaultValue: json["field_default_value"],
    fieldType: json["field_type"],
    fieldPlaceholder: json["field_placeholder"],
    fieldOptions: json["field_options"] != null ? new List<FieldOption>.from(json["field_options"].map((x) => FieldOption.fromMap(x))) : null,
    fieldCollection: json["field_collection"],
    fieldRequired: json["field_required"],
    fieldWidth: json["field_width"],
    fields: json["fields"] != null ? new List<Field>.from(json["fields"].map((x) => Field.fromMap(x))) : null,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "created_by_id": createdById,
    "updated_by_id": updatedById,
    "deleted_by_id": deletedById,
    "section_id": sectionId,
    "entity_type": entityType,
    "entity_id": entityId,
    "type": type,
    "name": name,
    "code": code,
    "subtitle": subtitle,
    "position": position,
    "field_default_value": fieldDefaultValue,
    "field_type": fieldType,
    "field_placeholder": fieldPlaceholder,
    "field_options": fieldOptions != null ? new List<dynamic>.from(fieldOptions.map((x) => x.toMap())) : null,
    "field_collection": fieldCollection,
    "field_required": fieldRequired,
    "field_width": fieldWidth,
    "fields": fields != null ? new List<Field>.from(fields.map((x) => x.toMap())) : null,
  };
}