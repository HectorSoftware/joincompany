import 'dart:convert';

class Business {
    int id;
    String createdAt;
    String updatedAt;
    String deletedAt;
    int createdById;
    int updatedById;
    int deletedById;
    int customerId;
    String name;
    String stage;
    String date;
    String amount;

    Business({
        this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.createdById,
        this.updatedById,
        this.deletedById,
        this.customerId,
        this.name,
        this.stage,
        this.date,
        this.amount,
    });

    factory Business.fromJson(String str) => Business.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Business.fromMap(Map<String, dynamic> json) => new Business(
        id: json["id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
        createdById: json["created_by_id"],
        updatedById: json["updated_by_id"],
        deletedById: json["deleted_by_id"],
        customerId: json["customer_id"],
        name: json["name"],
        stage: json["stage"],
        date: json["date"],
        amount: json["amount"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
        "created_by_id": createdById,
        "updated_by_id": updatedById,
        "deleted_by_id": deletedById,
        "customer_id": customerId,
        "name": name,
        "stage": stage,
        "date": date,
        "amount": amount,
    };
}