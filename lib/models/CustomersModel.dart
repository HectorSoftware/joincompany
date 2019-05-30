import 'dart:convert';

import 'package:joincompany/models/CustomerModel.dart';

class CustomersModel {
  int currentPage;
  List<CustomerModel> data;
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

  CustomersModel({
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

  factory CustomersModel.fromJson(String str) => CustomersModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CustomersModel.fromMap(Map<String, dynamic> json) => new CustomersModel(
    currentPage: json["current_page"],
    data: json["data"] != null ? new List<CustomerModel>.from(json["data"].map((x) => CustomerModel.fromMap(x))) : null,
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: json["per_page"],
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toMap() => {
    "current_page": currentPage,
    "data": data != null ? new List<CustomerModel>.from(data.map((x) => x.toMap())) : null,
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

class CustomersWithAddressModel
{
  int currentPage;
  List<CustomerWithAddressModel> data;
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

  CustomersWithAddressModel({
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

  factory CustomersWithAddressModel.fromJson(String str) => CustomersWithAddressModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CustomersWithAddressModel.fromMap(Map<String, dynamic> json) => new CustomersWithAddressModel(
    currentPage: json["current_page"],
    data: json["data"] != null ? new List<CustomerWithAddressModel>.from(json["data"].map((x) => CustomerWithAddressModel.fromMap(x))) : null,
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: int.parse(json["per_page"].toString()),
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toMap() => {
    "current_page": currentPage,
    "data": data != null ? new List<CustomerWithAddressModel>.from(data.map((x) => x.toMap())) : null,
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