import 'dart:convert';

import 'package:joincompany/models/TaskModel.dart';

class TasksModel {
  int currentPage;
  List<TaskModel> data;
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

  TasksModel({
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

  factory TasksModel.fromJson(String str) => TasksModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TasksModel.fromMap(Map<String, dynamic> json) => new TasksModel(
    currentPage: json["current_page"],
    data: json["data"] != null ? new List<TaskModel>.from(json["data"].map((x) => TaskModel.fromMap(x))) : null,
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
    "data": data != null ? new List<TaskModel>.from(data.map((x) => x.toMap())) : null,
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

  List<int> listTasksIds() {
    List<int> listOfTaskIds = List<int>();

    if(data != null)
      data.forEach((task) {
        if (task.id != null)
          listOfTaskIds.add(task.id);
      });
    return listOfTaskIds;
  }
}