import 'dart:convert';

import 'package:joincompany/models/ContactModel.dart';

class ContactsModel {
  int currentPage;
  List<ContactModel> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  String nextPageUrl;
  String path;
  int perPage;
  String prevPageUrl;
  int to;
  int total;

  ContactsModel({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory ContactsModel.fromJson(String str) => ContactsModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ContactsModel.fromMap(Map<String, dynamic> json) => new ContactsModel(
    currentPage: json["current_page"],
    data: json["data"] != null ? new List<ContactModel>.from(json["data"].map((x) => ContactModel.fromMap(x))) : null,
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: (json["per_page"]!=null && json["per_page"]!='') ? int.parse(json["per_page"]) : null,
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toMap() => {
    "current_page": currentPage,
    "data": data != null ? new List<ContactModel>.from(data.map((x) => x.toMap())) : null,
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}