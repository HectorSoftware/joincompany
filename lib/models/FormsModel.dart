import 'dart:convert';

import 'package:joincompany/models/FormModel.dart';

class FormsModel {
  int currentPage;
  List<FormModel> data;
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

  FormsModel({
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

  factory FormsModel.fromJson(String str) => FormsModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FormsModel.fromMap(Map<String, dynamic> json) => new FormsModel(
    currentPage: json["current_page"],
    data: json["data"] != null ? new List<FormModel>.from(json["data"].map((x) => FormModel.fromMap(x))) : null,
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

  factory FormsModel.fromDatabase(Map<String, dynamic> data) => new FormsModel(
  );

  Map<String, dynamic> toMap() => {
    "current_page": currentPage,
    "data": data != null ? new List<FormModel>.from(data.map((x) => x.toMap())) : null,
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

  List<int> listFormIds() {
    List<int> listOfFormIds = List<int>();

    if(data != null)
      data.forEach((form) {
        if (form.id != null)
          listOfFormIds.add(form.id);
      });
    return listOfFormIds;
  }
}
