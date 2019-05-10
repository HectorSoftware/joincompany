class User {
  final int id;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;
  final int createdById;
  final int updatedById;
  final int deletedById;
  final int supervisorId;
  final String name;
  final String code;
  final String email;
  final String phone;
  final String mobile;
  final String title;
  final String details;
  final String profile; //Quizás esto pueda ser un Enum



  User(this.id, this.createdAt, this.updatedAt, this.deletedAt, this.createdById, this.updatedById, this.deletedById, this.supervisorId, this.name, this.code, this.email, this.phone, this.mobile, this.title, this.details, this.profile);

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        deletedAt = json['deleted_at'],
        createdById = json['created_by_id'],
        updatedById = json['updated_by_id'],
        deletedById = json['deleted_by_id'],
        supervisorId = json['supervisor_id'],
        name = json['name'],
        code = json['code'],
        email = json['email'],
        phone = json['phone'],
        mobile = json['mobile'],
        title = json['title'],
        details = json['details'],
        profile = json['profile'];

  Map<String, dynamic> toJson() =>
    {
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'created_by_id': createdById,
      'updated_by_id': updatedById,
      'deleted_by_id': deletedById,
      'supervisor_id': supervisorId,
      'name': name,
      'code': code,
      'email': email,
      'phone': phone,
      'mobile': mobile,
      'title': title,
      'details': details,
      'profile': profile,
    };
}