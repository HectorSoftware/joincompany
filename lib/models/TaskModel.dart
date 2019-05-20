import 'dart:convert';

import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/CustomerModel.dart';

class Task {
 int id;
 String createdAt;
 String updatedAt;
 String deletedAt;
 int createdById;
 int updatedById;
 int deletedById;
 int formId;
 int responsibleId;
 int customerId;
 int addressId;
 String name;
 String planningDate;
 String checkinDate;
 double checkinLatitude;
 double checkinLongitude;
 int checkinDistance;
 String checkoutDate;
 double checkoutLatitude;
 double checkoutLongitude;
 int checkoutDistance;
 String status;
 List<CustomSection> customSections;
 List<CustomValue> customValues;
 Form form;
 Address address;
 Customer customer;
 Responsible responsible;

 Task({
   this.id,
   this.createdAt,
   this.updatedAt,
   this.deletedAt,
   this.createdById,
   this.updatedById,
   this.deletedById,
   this.formId,
   this.responsibleId,
   this.customerId,
   this.addressId,
   this.name,
   this.planningDate,
   this.checkinDate,
   this.checkinLatitude,
   this.checkinLongitude,
   this.checkinDistance,
   this.checkoutDate,
   this.checkoutLatitude,
   this.checkoutLongitude,
   this.checkoutDistance,
   this.status,
   this.customSections,
   this.customValues,
   this.form,
   this.address,
   this.customer,
   this.responsible,
 });

 factory Task.fromJson(String str) => Task.fromMap(json.decode(str));

 String toJson() => json.encode(toMap());

 factory Task.fromMap(Map<String, dynamic> json) => new Task(
   id: json["id"],
   createdAt: json["created_at"],
   updatedAt: json["updated_at"],
   deletedAt: json["deleted_at"],
   createdById: json["created_by_id"],
   updatedById: json["updated_by_id"],
   deletedById: json["deleted_by_id"],
   formId: json["form_id"],
   responsibleId: json["responsible_id"],
   customerId: json["customer_id"],
   addressId: json["address_id"],
   name: json["name"],
   planningDate: json["planning_date"],
   checkinDate: json["checkin_date"],
   checkinLatitude: json['checkin_latitude'] != null ? json["checkin_latitude"].toDouble() : null,
   checkinLongitude: json['checkin_longitude'] != null ? json["checkin_longitude"].toDouble() : null,
   checkinDistance: json["checkin_distance"],
   checkoutDate: json["checkout_date"],
   checkoutLatitude: json['checkout_latitude'] != null ? json["checkout_latitude"].toDouble() : null,
   checkoutLongitude: json['checkout_longitude'] != null ? json["checkout_longitude"].toDouble() : null,
   checkoutDistance: json["checkout_distance"],
   status: json["status"],
   customSections: json['custom_sections'] != null ? new List<CustomSection>.from(json["custom_sections"].map((x) => CustomSection.fromMap(x))) : null,
   customValues: json['custom_values'] != null ? new List<CustomValue>.from(json["custom_values"].map((x) => CustomValue.fromMap(x))) : null,
   form: json['form'] != null ? Form.fromMap(json["form"]) : null,
   address: json['address'] != null ? Address.fromMap(json["address"]) : null,
   customer: json['customer'] != null ? Customer.fromMap(json["customer"]) : null,
   responsible: json['responsible'] != null ? Responsible.fromMap(json["responsible"]) : null,
 );

 Map<String, dynamic> toMap() => {
   "id": id,
   "created_at": createdAt,
   "updated_at": updatedAt,
   "deleted_at": deletedAt,
   "created_by_id": createdById,
   "updated_by_id": updatedById,
   "deleted_by_id": deletedById,
   "form_id": formId,
   "responsible_id": responsibleId,
   "customer_id": customerId,
   "address_id": addressId,
   "name": name,
   "planning_date": planningDate,
   "checkin_date": checkinDate,
   "checkin_latitude": checkinLatitude,
   "checkin_longitude": checkinLongitude,
   "checkin_distance": checkinDistance,
   "checkout_date": checkoutDate,
   "checkout_latitude": checkoutLatitude,
   "checkout_longitude": checkoutLongitude,
   "checkout_distance": checkoutDistance,
   "status": status,
   "custom_sections": customSections != null ? new List<CustomSection>.from(customSections.map((x) => x.toMap())) : null,
   "custom_values": customValues != null ? new List<CustomValue>.from(customValues.map((x) => x.toMap())) : null,
   "form": form != null ? form.toMap() : null,
   "address": address != null ? address.toMap() : null,
   "customer": customer != null ? customer.toMap() : null,
   "responsible": responsible != null ? responsible.toMap() : null,
 };
}

class CustomSection {
  int id;
  String createdAt;
  String updatedAt;
  String deletedAt;
  int createdById;
  int updatedById;
  int deletedById;
  String entityType;
  int entityId;
  String type;
  String name;
  String code;
  String subtitle;
  String position;
  List<Field> fields;

  CustomSection({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.createdById,
    this.updatedById,
    this.deletedById,
    this.entityType,
    this.entityId,
    this.type,
    this.name,
    this.code,
    this.subtitle,
    this.position,
    this.fields,
  });

  factory CustomSection.fromJson(String str) => CustomSection.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CustomSection.fromMap(Map<String, dynamic> json) => new CustomSection(
    id: json["id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    createdById: json["created_by_id"],
    updatedById: json["updated_by_id"],
    deletedById: json["deleted_by_id"],
    entityType: json["entity_type"],
    entityId: json["entity_id"],
    type: json["type"],
    name: json["name"],
    code: json["code"],
    subtitle: json["subtitle"],
    position: json["position"],
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
    "entity_type": entityType,
    "entity_id": entityId,
    "type": type,
    "name": name,
    "code": code,
    "subtitle": subtitle,
    "position": position,
    "fields": fields != null ? new List<Field>.from(fields.map((x) => x.toMap())) : null,
  };
}

class CustomValue {
  int id;
  String createdAt;
  String updatedAt;
  int formId;
  int sectionId;
  int fieldId;
  String customizableType;
  int customizableId;
  String value;
  String imageBase64;
  Field field;

  CustomValue({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.formId,
    this.sectionId,
    this.fieldId,
    this.customizableType,
    this.customizableId,
    this.value,
    this.imageBase64,
    this.field,
  });

  factory CustomValue.fromJson(String str) => CustomValue.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CustomValue.fromMap(Map<String, dynamic> json) => new CustomValue(
    id: json["id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    formId: json["form_id"],
    sectionId: json["section_id"],
    fieldId: json["field_id"],
    customizableType: json["customizable_type"],
    customizableId: json["customizable_id"],
    value: json["value"],
    imageBase64: json["image_base64"],
    field: json['field'] != null ? Field.fromMap(json["field"]) : null,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "form_id": formId,
    "section_id": sectionId,
    "field_id": fieldId,
    "customizable_type": customizableType,
    "customizable_id": customizableId,
    "value": value,
    "image_base64": imageBase64,
    "field": field != null ? field.toMap() : null,
  };
}

class Responsible {
  int id;
  String createdAt;
  String updatedAt;
  String deletedAt;
  int createdById;
  int updatedById;
  int deletedById;
  int supervisorId;
  String name;
  String code;
  String email;
  String phone;
  String mobile;
  String title;
  String details;
  String profile;
  Responsible supervisor;

  Responsible({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.createdById,
    this.updatedById,
    this.deletedById,
    this.supervisorId,
    this.name,
    this.code,
    this.email,
    this.phone,
    this.mobile,
    this.title,
    this.details,
    this.profile,
    this.supervisor,
  });

  factory Responsible.fromJson(String str) => Responsible.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Responsible.fromMap(Map<String, dynamic> json) => new Responsible(
    id: json["id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    createdById: json["created_by_id"],
    updatedById: json["updated_by_id"],
    deletedById: json["deleted_by_id"],
    supervisorId: json["supervisor_id"],
    name: json["name"],
    code: json["code"],
    email: json["email"],
    phone: json["phone"],
    mobile: json["mobile"],
    title: json["title"],
    details: json["details"],
    profile: json["profile"],
    supervisor: json["supervisor"] != null ? Responsible.fromMap(json["supervisor"]) : null,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "created_by_id": createdById,
    "updated_by_id": updatedById,
    "deleted_by_id": deletedById,
    "supervisor_id": supervisorId,
    "name": name,
    "code": code,
    "email": email,
    "phone": phone,
    "mobile": mobile,
    "title": title,
    "details": details,
    "profile": profile,
    "supervisor": supervisor != null ? supervisor.toMap() : null,
  };
}


