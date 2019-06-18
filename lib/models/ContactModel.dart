import 'dart:convert';

class ContactModel {
    int id;
    String createdAt;
    String updatedAt;
    String deletedAt;
    int createdById;
    int updatedById;
    int deletedById;
    String name;
    String phone;
    String email;
    String details;

    ContactModel({
        this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.createdById,
        this.updatedById,
        this.deletedById,
        this.name,
        this.phone,
        this.email,
        this.details,
    });

    factory ContactModel.fromJson(String str) => ContactModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ContactModel.fromMap(Map<String, dynamic> json) => new ContactModel(
        id: json["id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
        createdById: json["created_by_id"],
        updatedById: json["updated_by_id"],
        deletedById: json["deleted_by_id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        details: json["details"],
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
        "phone": phone,
        "email": email,
        "details": details,
    };
}