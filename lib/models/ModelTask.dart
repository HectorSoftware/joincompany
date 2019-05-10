class Task {
  final int id;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;
  final int createdById;
  final int updatedById;
  final int deletedById;
  final int formId;
  final int responsibleId;
  final int customerId;
  final int addressId;
  final String name;
  final String planningDate;
  final String checkinDate;
  final String checkinLatitude;
  final String checkinLongitude;
  final String checkinDistance;
  final String checkoutDate;
  final String checkoutLatitude;
  final String checkoutLongitude;
  final String checkoutDistance;
  final String status; // Quizás esto pueda ser un Enum
  final String customSections; // Se necesita ver esta estructura para definir su tipo
  final String customValues; // Se necesita ver esta estructura para definir su tipo



  Task(this.id, this.createdAt, this.updatedAt, this.deletedAt, this.createdById, this.updatedById, this.deletedById, this.formId, this.responsibleId, this.customerId, this.addressId, this.name, this.planningDate, this.checkinDate, this.checkinLatitude, this.checkinLongitude, this.checkinDistance, this.checkoutDate, this.checkoutLatitude, this.checkoutLongitude, this.checkoutDistance, this.status, this.customSections, this.customValues );

  Task.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        deletedAt = json['deleted_at'],
        createdById = json['created_by_id'],
        updatedById = json['updated_by_id'],
        deletedById = json['deleted_by_id'],
        formId = json['form_id'],
        responsibleId = json['responsible_id'],
        customerId = json['customer_id'],
        addressId = json['address_id'],
        name = json['name'],
        planningDate = json['planning_date'],
        checkinDate = json['checkin_date'],
        checkinLatitude = json['checkin_latitude'],
        checkinLongitude = json['checkin_longitude'],
        checkinDistance = json['checkin_distance'],
        checkoutDate = json['checkout_date'],
        checkoutLatitude = json['checkout_latitude'],
        checkoutLongitude = json['checkout_longitude'],
        checkoutDistance = json['checkout_distance'],
        status = json['status'],
        customSections = json['custom_sections'],
        customValues = json['custom_values'];

  Map<String, dynamic> toJson() =>
    {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'created_by_id': createdById,
      'updated_by_id': updatedById,
      'deleted_by_id': deletedById,
      'form_id': formId,
      'responsible_id': responsibleId,
      'customer_id': customerId,
      'address_id': addressId,
      'name': name,
      'planning_date': planningDate,
      'checkin_date': checkinDate,
      'checkin_latitude': checkinLatitude,
      'checkin_longitude': checkinLongitude,
      'checkin_distance': checkinDistance,
      'checkout_date': checkoutDate,
      'checkout_latitude': checkoutLatitude,
      'checkout_longitude': checkoutLongitude,
      'checkout_distance': checkoutDistance,
      'status': status,
      'custom_sections': customSections,
      'custom_values': customValues,
    };
}


