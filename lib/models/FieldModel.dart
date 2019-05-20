import 'dart:convert';

class FieldModel {
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
  List<FieldOptionModel> fieldOptions;
  String fieldCollection;
  bool fieldRequired;
  int fieldWidth;

  FieldModel({
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
  });

  factory FieldModel.fromJson(String str) => FieldModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FieldModel.fromMap(Map<String, dynamic> json) => new FieldModel(
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
    fieldOptions: json["field_options"] != null ? new List<FieldOptionModel>.from(json["field_options"].map((x) => FieldOptionModel.fromMap(x))) : null,
    fieldCollection: json["field_collection"],
    fieldRequired: json["field_required"],
    fieldWidth: json["field_width"],
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
    "field_options": fieldOptions != null ? new List<FieldOptionModel>.from(fieldOptions.map((x) => x.toMap())) : null,
    "field_collection": fieldCollection,
    "field_required": fieldRequired,
    "field_width": fieldWidth,
  };
}


class FieldOptionModel {
  int value;
  String name;

  FieldOptionModel({
    this.value,
    this.name,
  });

  factory FieldOptionModel.fromJson(String str) => FieldOptionModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FieldOptionModel.fromMap(Map<String, dynamic> json) => new FieldOptionModel(
    value: json["value"],
    name: json["name"],
  );

  Map<String, dynamic> toMap() => {
    "value": value,
    "name": name,
  };
}